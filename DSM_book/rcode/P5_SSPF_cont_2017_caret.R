# ******************************************************************************
# *                                                                            
# *                           [Caret R package for digital soil mapping]                                
# *                                                                            
# *  Description:                                                              
##  Some brief introduction to harnessing the R Caret package for digital soil mapping

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
# *  2023-09-13             
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

# libraries
library(ithir)
library(terra)
library(sf)
library(caret)

# point data
data(HV_subsoilpH)

# Start afresh round pH data to 2 decimal places
HV_subsoilpH$pH60_100cm <- round(HV_subsoilpH$pH60_100cm, 2)

# remove already intersected data
HV_subsoilpH <- HV_subsoilpH[, 1:3]

# add an id column
HV_subsoilpH$id <- seq(1, nrow(HV_subsoilpH), by = 1)

# re-arrange order of columns
HV_subsoilpH <- HV_subsoilpH[, c(4, 1, 2, 3)]

# Change names of coordinate columns
names(HV_subsoilpH)[2:3] <- c("x", "y")
# save a copy of coordinates
HV_subsoilpH$x2 <- HV_subsoilpH$x
HV_subsoilpH$y2 <- HV_subsoilpH$y

# convert data to sf object
HV_subsoilpH <- sf::st_as_sf(x = HV_subsoilpH, coords = c("x", "y"))

# grids (covariate rasters from ithir package)
hv.sub.rasters <- list.files(path = system.file("extdata/", package = "ithir"), pattern = "hunterCovariates_sub", full.names = TRUE)

# read them into R as SpatRaster objects
hv.sub.rasters <- terra::rast(hv.sub.rasters)

# extract covariate data
DSM_data <- terra::extract(x = hv.sub.rasters, y = HV_subsoilpH, bind = T, method = "simple")
DSM_data <- as.data.frame(DSM_data)

# check for NA values
which(!complete.cases(DSM_data))
DSM_data<- DSM_data[complete.cases(DSM_data),]


## Begin the Caret work

## General model forms
## # 1.
 fit <- train(form = pH60_100cm ~ AACN +
               Landsat_Band1 + Elevation + Hillshading +
               Mid_Slope_Positon + MRVBF + NDVI +
               TWI, data = DSM_data, method = "lm")
 
## # or 2.
 fit <- train(
   x = DSM_data[, c(6,7,8,9,11,12,13,14)],
   y = DSM_data$pH60_100cm,
   method = "lm")

## embedded k-fold cross validation
fit <- train(
  x = DSM_data[, c(6,7,8,9,11,12,13,14)],
  y = DSM_data$pH60_100cm,
  method = "lm",
  trControl = trainControl(
    method = 'repeatedcv',
    number = 5,
    repeats = 10
  )
)

fit

## Model availability
list_of_models <- modelLookup()
head(list_of_models)

#The number of models caret interfaces with
nrow(list_of_models)

## Common DSM models
#Cubist model
modelLookup(model = "cubist")
fit_cubist <- train(
   x = DSM_data[, c(6,7,8,9,11,12,13,14)],
  y = DSM_data$pH60_100cm,
  method = "cubist",
  trControl = trainControl(
    method = 'cv',
    number = 5
  )
)

#random forest model
modelLookup(model = "rf")
fit_rf <- train(
  x = DSM_data[, c(6,7,8,9,11,12,13,14)],
  y = DSM_data$pH60_100cm,
  method = "rf",
  trControl = trainControl(
    method = 'cv',
    number = 5
  )
)

## Apply model spatially
## #Cubist model
pred_cubist <- predict(fit_cubist, DSM_data)
## 
## #To raster data
pred_cubistMap <- terra::predict(hv.sub.rasters, fit_cubist)
plot(pred_cubistMap)

##END



