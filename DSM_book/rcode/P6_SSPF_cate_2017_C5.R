# ******************************************************************************
# *                                                                            
# *                           [C5 Modeling for digital soil mapping]                                
# *                                                                            
# *  Description:                                                              
##    
#
# * 
# *       
# *       
# *       
# *                                                                            
# *  Created By:                                                               
# *  Budiman Minansy; Brendan Malone                                                
# *                                                                            
# *  Last Modified:                                                            
# *  2023-09-19             
# *                                                                            
# *  License:   
# *     Data Usage License (Data-UL)                                             
# *                                                                            
# *   Permission is hereby granted, free of charge, to any person obtaining a    
# *   copy of this data and associated code files (the "Data"), to use the Data  
# *   for any lawful purpose, including but not limited to analysis, research,   
# *   and reporting, without modification of the original Data or sharing any   
# *   modified versions of the Data.      
#
# *   Users of the Data must provide proper attribution to the original source   
# *   of the Data in any publication, research, or derivative works by including 
# *   the following attribution:  
# *
# *   1. Malone, B. P., Minasny, B. & McBratney, A. B. (2017). 
# *   Using R for Digital Soil Mapping, Cham, Switzerland: Springer International Publishing. 
# *   https://doi.org/10.1007/978-3-319-44327-0#
# *   
# *
# *  The Data is provided "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
# *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
# *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    
# *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR      
# *  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,      
# *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA OR THE USE OR OTHER   
# *  DEALINGS IN THE DATA                                                                       
# ******************************************************************************


## load libraries
library(ithir)
library(sf)
library(terra)
library(C50)

# point data of terron classifications 
data(hvTerronDat)

# environmental covariates
# grids (covariate rasters from ithir package)
hv.rasters <- list.files(path = system.file("extdata/", package = "ithir"), pattern = "hunterCovariates_A", full.names = T)
hv.rasters

# read them into R as SpatRaster objects
hv.rasters <- terra::rast(hv.rasters)


## coerce point data to spatial object
hvTerronDat<- sf::st_as_sf(x = hvTerronDat,coords = c("x", "y"))


## Covariate data extraction
DSM_data<- terra::extract(x = hv.rasters,y = hvTerronDat, bind = T, method = "simple")
DSM_data<- as.data.frame(DSM_data)
str(DSM_data)

## remove missing data
which(!complete.cases(DSM_data))
DSM_data<- DSM_data[complete.cases(DSM_data),]

## Random holdback
set.seed(655)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))


## Fit model
names(DSM_data)
hv.C5 <- C5.0(x = DSM_data[training, 2:9],
                y = DSM_data$terron[training], trials = 1, rules = FALSE, 
              control = C5.0Control(CF = 0.95, minCases = 20, earlyStopping = FALSE))

# model summary and structure
summary(hv.C5)

#return the class predictions
predict(hv.C5, newdata = DSM_data[training, ])[1:10]
 
#return the class probabilities
predict(hv.C5, newdata = DSM_data[training, ], type = "prob")[1:10,1:3]

## Goodness of fit calibration data
C.pred.hv.C5 <- predict(hv.C5, newdata = DSM_data[training, ])
goofcat(observed = DSM_data$terron[training] , predicted = C.pred.hv.C5 )

## Goodness of fit out-of-bag data
V.pred.hv.C5 <- predict(hv.C5, newdata = DSM_data[-training, ])
goofcat(observed = DSM_data$terron[-training] , predicted = V.pred.hv.C5 )

## Applying model spatially
#class prediction
map.C5.c<- terra::predict(object = hv.rasters, model = hv.C5, 
                          type="class")

# mask [the C5 model extends to outside the mapping area]
msk <- terra::ifel(is.na(hv.rasters[[1]]), NA, 1)
map.C5.c.masked <- terra::mask(map.C5.c, msk, inverse = F)

# plot map
map.C5.c.masked <- as.factor(map.C5.c.masked)
# some classes were dropped out !!
levels(map.C5.c.masked)[[1]]

## HEX colors
area_colors <- c("#FF0000", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", "#FFA77F", "#7AF5CA", "#D7B09E", "#CCCCCC")
terra::plot(map.C5.c.masked, col = area_colors,
            plg=list(legend = c("HVT_001", 
                                "HVT_003","HVT_004",
                                "HVT_005","HVT_006", 
                                "HVT_007", "HVT_008", 
                                "HVT_009", "HVT_010"), cex= 0.75, title = "Terron Class"))


## END
