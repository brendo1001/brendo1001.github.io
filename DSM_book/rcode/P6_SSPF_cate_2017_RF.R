# ******************************************************************************
# *                                                                            
# *                           [Using the random forest model for categorical attributes]                                
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

## Load R libraries
library(ithir)
library(sf)
library(terra)
library(randomForest)

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
hv.RF <- randomForest(terron ~ hunterCovariates_A_AACN + hunterCovariates_A_elevation + 
                        hunterCovariates_A_Hillshading +   
                        hunterCovariates_A_light_insolation + hunterCovariates_A_MRVBF +          
                        hunterCovariates_A_Slope + hunterCovariates_A_TRI + 
                        hunterCovariates_A_TWI, data = DSM_data[training, ], 
                      ntree = 500, mtry = 5)


#Output random forest model diagnostics
print(hv.RF)

#output relative importance of each covariate
importance(hv.RF)


#Prediction of classes
head(predict(hv.RF, type = "response", newdata = DSM_data[training, ]))

#Class probabilities
head(predict(hv.RF, type = "prob", newdata = DSM_data[training, ]))

# Goodness of fit calibration 
C.pred.hv.RF <- predict(hv.RF, newdata = DSM_data[training, ])
goofcat(observed = DSM_data$terron[training] , predicted = C.pred.hv.RF )

## Goodness of fit validation
V.pred.hv.RF <- predict(hv.RF, newdata = DSM_data[-training, ])
goofcat(observed = DSM_data$terron[-training] , predicted = V.pred.hv.RF )

## Apply model spatially
# class prediction
map.RF.c<- terra::predict(object = hv.rasters, model = hv.RF)

## plotting
map.RF.c <- as.factor(map.RF.c)
## HEX colors
area_colors <- c("#FF0000", "#38A800", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", "#FFA77F", "#7AF5CA", "#D7B09E", "#CCCCCC", "#B4D79E", "#FFFF00")
terra::plot(map.RF.c, col = area_colors,
            plg=list(legend = c("HVT_001","HVT_002", 
                                "HVT_003","HVT_004",
                                "HVT_005","HVT_006", 
                                "HVT_007", "HVT_008", 
                                "HVT_009", "HVT_010", 
                                "HVT_011", "HVT_012"), cex= 0.75, title = "Terron Class"))


## END
