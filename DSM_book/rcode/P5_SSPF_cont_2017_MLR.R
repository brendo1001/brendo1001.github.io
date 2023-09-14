# ******************************************************************************
# *                                                                            
# *                           [multiple linear regression]                                
# *                                                                            
# *  Description:                                                              
## Fitting a multiple linear regression model to soil data with the intent of mapping
## Random Holdback validation
## 
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
# *  2023-09-112              
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

# load libraries
library(ithir)
library(terra)
library(sf)
library(viridis)

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

# Fit MLR with all covariates
hv.MLR.Full <- lm(pH60_100cm ~  + Terrain_Ruggedness_Index + AACN + 
                    Landsat_Band1 + Elevation + Hillshading + 
                    Light_insolation + Mid_Slope_Positon + MRVBF + NDVI + 
                    TWI + Slope, data = DSM_data)
summary(hv.MLR.Full)

# select covariates from full model using stepwise selection
hv.MLR.Step <- step(hv.MLR.Full, trace = 0, direction = "both")
summary(hv.MLR.Step)

# Use selected covariates to fit model but this time have a calibration and out-of-bag data sets
set.seed(123)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
hv.MLR.rh <- lm(pH60_100cm ~ AACN + 
                  Landsat_Band1 + Elevation + Hillshading + 
                  Mid_Slope_Positon + MRVBF + NDVI + 
                  TWI, data = DSM_data[training, ])
#calibration predictions
hv.pred.rhC <- predict(hv.MLR.rh, DSM_data[training, ])

# apply predictions to out-of-bag cases
hv.pred.rhV <- predict(hv.MLR.rh, DSM_data[-training, ])

# model evaluation
#calibration
goof(observed = DSM_data$pH60_100cm[training] , predicted = hv.pred.rhC )

#validation
goof(observed = DSM_data$pH60_100cm[-training] , predicted = hv.pred.rhV )

# apply model spatially
map.MLR.r1<- terra::predict(object = hv.sub.rasters, model = hv.MLR.rh, filenames = "soilpH_60_100_MLR.tif", datatype = "FLT4S", overwrite = TRUE)


# # prediction interval function
predfun <- function(model, data) {
  v <- terra::predict(model, data, interval = 'prediction', level = 0.90)}

# perform the predictions
# lower prediction limit
map.MLR.r.1ow<- terra::predict(object = hv.sub.rasters, model = hv.MLR.rh, filename = "soilPh_60_100_MLR_low.tif", fun = predfun, index = 2, overwrite = TRUE)

# mean prediction
map.MLR.r.pred<- predict(object = hv.sub.rasters, model = hv.MLR.rh, filename = "soilPh_60_100_MLR_pred.tif", fun = predfun, index = 1, overwrite = TRUE  )

# upper prediction limit
map.MLR.r.up<- predict(object = hv.sub.rasters, model = hv.MLR.rh, filename = "soilPh_60_100_MLR_pred_up.tif", fun = predfun, index = 3, overwrite = TRUE  )
#check working directory for presence of rasters

## plot map on the same scale for better comparison
# stack
stacked.preds<- c(map.MLR.r.1ow,
                  map.MLR.r.pred,
                  map.MLR.r.up)
stacked.preds

rmin<- min(terra::minmax(stacked.preds))
rmax<- max(terra::minmax(stacked.preds))
# plotting parameter
par(mfrow = c(3, 1))

plot(stacked.preds[[1]], col=viridis(50), breaks=round(seq(rmin,rmax,length.out=10),digits = 1), legend=T, bty="n", box = FALSE, main = "MLR predicted soil pH (60-100cm) lower limit") 

plot(stacked.preds[[2]], col=viridis(50), breaks=round(seq(rmin,rmax,length.out=10),digits = 1), legend=T, bty="n", box = FALSE, main = "MLR predicted soil pH (60-100cm) mean prediction")

plot(stacked.preds[[3]], col=viridis(50), breaks=round(seq(rmin,rmax,length.out=10),digits = 1), legend=T, bty="n", box = FALSE, main = "MLR predicted soil pH (60-100cm) upper limit")

## END