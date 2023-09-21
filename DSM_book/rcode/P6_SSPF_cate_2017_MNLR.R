# ******************************************************************************
# *                                                                            
# *                           [Multinomial logistic regression for digital soil mapping]                                
# *                                                                            
# *  Description:                                                              
##  
#
#
# * 
# *       
# *       
# *       
# *                                                                            
# *  Created By:                                                               
# *  Brendan Malone                                                
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
# *   Malone, B. P., Minasny, B. & McBratney, A. B. (2017). 
# *   Using R for Digital Soil Mapping, Cham, Switzerland: Springer International Publishing. 
# *   https://doi.org/10.1007/978-3-319-44327-0#
#
# *  The Data is provided "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
# *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
# *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    
# *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR      
# *  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,      
# *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA OR THE USE OR OTHER   
# *  DEALINGS IN THE DATA                                                                       
# ******************************************************************************

## Get data
library(ithir)
library(sf)
library(terra)
library(rasterVis)
library(nnet)


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

## Multinomial logistic regression model
set.seed(655)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
hv.MNLR <- nnet::multinom(terron ~ hunterCovariates_A_AACN + hunterCovariates_A_elevation + hunterCovariates_A_Hillshading +   
                      hunterCovariates_A_light_insolation + hunterCovariates_A_MRVBF +          
                      hunterCovariates_A_Slope + hunterCovariates_A_TRI + hunterCovariates_A_TWI, 
                    data = DSM_data[training, ])

## Model summary
summary(hv.MNLR)
## 
#Estimate class probabilities
probs.hv.MNLR <- fitted(hv.MNLR)
 
#return top of data frame of probabilities
head(probs.hv.MNLR)

## model prediction
pred.hv.MNLR <- predict(hv.MNLR)
summary(pred.hv.MNLR)

## goodness of fit (calibration)
ithir::goofcat(observed = DSM_data$terron[training] , predicted = pred.hv.MNLR )

## goodness of fit (out-of-bag)
V.pred.hv.MNLR <- predict(hv.MNLR, newdata = DSM_data[-training, ])
ithir::goofcat(observed = DSM_data$terron[-training] , predicted = V.pred.hv.MNLR )

## Apply model spatially
## #class prediction
map.MNLR.c<- terra::predict(object = hv.rasters, model = hv.MNLR, type="class")
 
## #class probabilities
map.MNLR.p<- terra::predict(object = hv.rasters, model = hv.MNLR, type="probs",
              index = 1)

## Plotting
map.MNLR.c <- as.factor(map.MNLR.c)
## HEX colors
area_colors <- c("#FF0000", "#38A800", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", "#FFA77F", "#7AF5CA", "#D7B09E", "#CCCCCC", "#B4D79E", "#FFFF00")
terra::plot(map.MNLR.c, col = area_colors,
            plg=list(legend = c("HVT_001","HVT_002", 
                                "HVT_003","HVT_004",
                                "HVT_005","HVT_006", 
                                "HVT_007", "HVT_008", 
                                "HVT_009", "HVT_010", 
                                "HVT_011", "HVT_012"), cex= 0.75, title = "Terron Class"))


## END
