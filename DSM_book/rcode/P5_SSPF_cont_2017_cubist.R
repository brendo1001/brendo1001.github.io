# ******************************************************************************
  # *                                                                            
  # *                           [multiple linear regression]                                
  # *                                                                            
  # *  Description:                                                              
  ##  Cubist modelling for digital soil mapping
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

library(ithir)
library(terra)
library(sf)
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



## Cubist model fitting
# select a random set by holdback for model calibration
set.seed(875)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
mDat <- DSM_data[training, ]

#fit the model
hv.cub.Exp <- cubist(x = mDat[, c("AACN", "Landsat_Band1", "Elevation",
              "Hillshading", "Mid_Slope_Positon", "MRVBF", "NDVI", 
              "TWI")], y = mDat$pH60_100cm, 
              cubistControl(rules = 100, extrapolation = 15), committees = 1)

## -Model summary
summary(hv.cub.Exp)

## Goodness of fit
#Internal validation
Cubist.pred.C <- predict(hv.cub.Exp, newdata = DSM_data[training,])
goof(observed = DSM_data$pH60_100cm[training] , predicted = Cubist.pred.C )

#External validation
Cubist.pred.V <- predict(hv.cub.Exp, newdata = DSM_data[-training,])
goof(observed = DSM_data$pH60_100cm[-training] , predicted = Cubist.pred.V )

## Spatial prediction
map.cubist.r1<- terra::predict(object = hv.sub.rasters, model = hv.cub.Exp,
                 filename = "soilpH_60_100_cubist.tif", datatype = "FLT4S", overwrite = TRUE  )

plot(map.cubist.r1, main = "Cubist model predicted Hunter Valley soil pH (60-100cm)")


## END



