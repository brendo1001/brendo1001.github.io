# ******************************************************************************
# *                                                                            
# *                           [Universal Kriging]                                
# *                                                                            
# *  Description:                                                              
##  Universal kriging implemented through the gstat R package
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


# model calibration dataset
set.seed(123)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
cDat<- DSM_data[training, ]
names(cDat)[3:4]<- c("x", "y")

## fit universal kriging model 
vgm1 <- variogram(pH60_100cm~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI,  ~x+y, data = cDat, width = 200, cutoff = 3000)

mod<-vgm(psill= var(cDat$pH60_100cm), "Exp", range= 3000, nugget = 0) 

model_1 <- fit.variogram(vgm1, mod)
model_1

plot(vgm1, model = model_1)

# Universal kriging model object
gUK <- gstat(NULL, "pH", pH60_100cm ~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI, data = cDat, locations = ~x+y, model=model_1)
gUK


## out-of-bag data
vDat<- DSM_data[-training,]
names(vDat)[3:4]<- c("x", "y")

#make the predictions on out-of-bag data
UK.preds.V<- krige(pH60_100cm ~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI, cDat,locations = ~x+y, model=model_1, newdata= vDat)

# evaluate UK predictions
goof(observed = DSM_data$pH60_100cm[-training] , predicted = c(UK.preds.V[,3]), plot.it = T)


## Apply model spatially
par(mfrow = c(1, 2))
## # prediction and prediction variance
UK.P.map <- terra::interpolate(object = hv.sub.rasters, gUK, xyOnly=FALSE)
plot(UK.P.map[[1]], main= "Universal kriging predictions")
plot(UK.P.map[[2]], main= "prediction variance")

## END
