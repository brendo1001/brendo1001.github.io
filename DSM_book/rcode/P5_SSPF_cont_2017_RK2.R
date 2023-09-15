## Regression Kriging. 
## Cubist modeling of environmental trend followed by variogram model of cubist model residuals 
# ******************************************************************************
# *                                                                            
# *                           [Regression Kriging]                                
# *                                                                            
# *  Description:                                                              
# * Regression Kriging. 
# * Cubist modeling of environmental trend followed by variogram model of cubist model residuals 

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
# *  2023-09-14             
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
library(MASS)
library(terra)
library(sf)
library(gstat)
library(Cubist)

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


## Cubist modeling of environmental trend
set.seed(875)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
mDat <- DSM_data[training, ]
names(mDat)[3:4]<- c("x", "y")

#fit the model
hv.cub.Exp <- cubist(x = mDat[, c("AACN", "Landsat_Band1", "Elevation",
              "Hillshading", "Mid_Slope_Positon", "MRVBF", "NDVI", 
              "TWI")], y = mDat$pH60_100cm, 
              cubistControl(rules = 100, extrapolation = 15), committees = 1)


## Model residuals
mDat$residual <- mDat$pH60_100cm - predict(hv.cub.Exp, newdata = mDat)
mean(mDat$residual)
hist(mDat$residual)

## calculate variogram
vgm1 <- variogram(residual~1,~x+y, mDat, width = 200, cutoff = 3000)

# initialise variogram model
mod<-vgm(psill= var(mDat$residual), "Sph", range= 3000, nugget = 0) 

# fit model
model_1 <- fit.variogram(vgm1, mod)
model_1
plot(vgm1, model = model_1)

# Residual kriging model
gRK <- gstat(NULL, "RKresidual", residual~1, locations = ~x+y, mDat, model=model_1)
gRK


## Model evaluation on out-of-bag data

# Cubist model predictions
Cubist.pred.V <- predict(hv.cub.Exp, newdata = DSM_data[-training,])

#Cubist model with residual variogram
vDat<- DSM_data[-training,]
names(vDat)[3:4]<- c("x", "y")

#make the residual predictions
RK.preds.V<- krige(residual~1, mDat, locations = ~x+y, model=model_1, newdata= vDat)

#Sum the two components together
RK.preds.fin<- Cubist.pred.V + RK.preds.V[,3]

# evaluation based on cubist model only
goof(observed = DSM_data$pH60_100cm[-training] , predicted = Cubist.pred.V, plot.it = T )

#validation regression kriging with cubist model
goof(observed = DSM_data$pH60_100cm[-training] , predicted = RK.preds.fin, plot.it = T)

## Spatial prediction
par(mfrow = c(3, 1))

# Cubist model
map.RK1<- terra::predict(object = hv.sub.rasters, model = hv.cub.Exp,
          filename = "soilpH_60_100_cubistRK.tif",
          datatype = "FLT4S", overwrite = TRUE  )
 plot(map.RK1, main = "Cubist model predicted soil pH")

## Interpolated residuals 
map.RK2<- terra::interpolate(object = hv.sub.rasters, model = gRK, xyOnly=TRUE,
           index = 1, filename = "soilpH_60_100_residualRK.tif", datatype = "FLT4S", overwrite = TRUE)
 plot(map.RK2, main = "Kriged residual")

 
## Sum of cubist predictions and residuals 
## #Stack prediction and kriged residuals
pred.stack<- c(map.RK1, map.RK2)
map.RK3 <- sum(pred.stack)
plot(map.RK3, main = "Regression kriging prediction")

## END



