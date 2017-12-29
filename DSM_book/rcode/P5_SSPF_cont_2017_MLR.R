## FItting a multiple linear regression model to soil data with the intent of mapping
## Random Holdback validation
## Different methods for applying a model spatially: 1) using a data table. 2) via rasters. 3) via parallel processing


#libraries
library(ithir)
library(raster)
library(rgdal)
library(sp)

#point data
data(HV_subsoilpH)

# Start afresh 
#round pH data to 2 decimal places
HV_subsoilpH$pH60_100cm<- round(HV_subsoilpH$pH60_100cm, 2)

#remove already intersected data
HV_subsoilpH<- HV_subsoilpH[,1:3]

#add an id column
HV_subsoilpH$id<- seq(1, nrow(HV_subsoilpH), by = 1)

#re-arrange order of columns
HV_subsoilpH<- HV_subsoilpH[,c(4,1,2,3)]

#Change names of coordinate columns
names(HV_subsoilpH)[2:3]<- c("x", "y")


#grids (covariate raster)
data(hunterCovariates_sub)

## make data a sptatial object
coordinates(HV_subsoilpH)<- ~ x + y

# covariate data extract
DSM_data<- extract(hunterCovariates_sub, HV_subsoilpH, sp= 1, method = "simple")
DSM_data<- as.data.frame(DSM_data)
str(DSM_data)

## remove any missing values
which(!complete.cases(DSM_data))
DSM_data<- DSM_data[complete.cases(DSM_data),]

## Fit a model with all covariates
hv.MLR.Full <- lm(pH60_100cm ~  + Terrain_Ruggedness_Index + AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Light_insolation + Mid_Slope_Positon + MRVBF + NDVI + 
              TWI + Slope, data = DSM_data)
summary(hv.MLR.Full)

##Perfrom a stepwise regression to filter out unecessary variables
hv.MLR.Step <- step(hv.MLR.Full, trace = 1, direction = "both")
summary(hv.MLR.Step)

## Random holdback
set.seed(123)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
hv.MLR.rh <- lm(pH60_100cm ~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI, data = DSM_data[training, ])

#calibration predictions
hv.pred.rhC <- predict(hv.MLR.rh, DSM_data[training, ])

#validation predictions
hv.pred.rhV <- predict(hv.MLR.rh, DSM_data[-training, ])

## Goodness of fit
#calibration
goof(observed = DSM_data$pH60_100cm[training] , predicted = hv.pred.rhC )

#validation
goof(observed = DSM_data$pH60_100cm[-training] , predicted = hv.pred.rhV )


### Applyinh the model spatially.

## -covariate data table
## Below is just combining all the raster data into a single data frame
data(hunterCovariates_sub)
tempD <- data.frame(cellNos = seq(1:ncell(hunterCovariates_sub)))
vals <- as.data.frame(getValues(hunterCovariates_sub))
tempD<- cbind(tempD, vals)
tempD <- tempD[complete.cases(tempD), ]
cellNos <- c(tempD$cellNos)
gXY <- data.frame(xyFromCell(hunterCovariates_sub, cellNos, spatial = FALSE))
tempD<- cbind(gXY, tempD)
str(tempD)

## Predict
map.MLR <- predict(hv.MLR.rh, newdata = tempD)
map.MLR <- cbind(data.frame(tempD[, c("x", "y")]), map.MLR)

## Plot and export map
map.MLR.r <- rasterFromXYZ(as.data.frame(map.MLR[, 1:3]))
plot(map.MLR.r, main = "MLR predicted soil pH (60-100cm)")

## #set the projection
crs(map.MLR.r)<- "+proj=utm +zone=56 + south + ellps=WGS84 +datum=WGS84 +units=m +no_defs"

# Export
##writeRaster(map.MLR.r, "soilpH_60_100_MLR.tif", format = "GTiff",
##             datatype = "FLT4S", overwrite = TRUE)
## #check working directory for presence of raster


## Apply the model given raster data
map.MLR.r1<- predict(hunterCovariates_sub, hv.MLR.rh, "soilpH_60_100_MLR.tif", format = "GTiff", datatype = "FLT4S", overwrite = TRUE  )


## Upper and Lower prediction intervals
par(mfrow = c(3, 1))

#
predfun <- function(model, data) {
v <- predict(model, data, interval= 'prediction', level = 0.90)}

## Lower prediction interval 
## map.MLR.r.1ow<- predict(hunterCovariates_sub, hv.MLR.rh,
##                 "soilPh_60_100_MLR_low.tif",
##                 fun = predfun, index =2,format = "GTiff",
##                 datatype = "FLT4S", overwrite = TRUE  )
## plot(map.MLR.r.1ow, main = "MLR predicted soil pH (60-100cm) lower limit")

## Model prediction 
## map.MLR.r.pred<- predict(hunterCovariates_sub, hv.MLR.rh,
##                  "soilPh_60_100_MLR_pred.tif",
##                  fun = predfun, index =1, format = "GTiff",
##                  datatype = "FLT4S", overwrite = TRUE  )
## plot(map.MLR.r.pred, main = "MLR predicted soil pH (60-100cm)")

## Upper prediction interval 
## map.MLR.r.up<- predict(hunterCovariates_sub, hv.MLR.rh,
##                "soilPh_60_100_MLR_up.tif",
##                fun = predfun, index =3,format = "GTiff",
##                datatype = "FLT4S", overwrite = TRUE  )
## plot(map.MLR.r.up, main = "MLR predicted soil pH (60-100cm) upper limit")


## Parallel processing of applying model spatially with raster data (Useful for very large rasters)
library(parallel)
beginCluster(4)
cluserMLR.pred <- clusterR(hunterCovariates_sub, predict,
                   args=list(hv.MLR.rh),
                   filename= "soilpH_60_100_MLR_pred.tif",
                   format="GTiff", progress= FALSE,
                   overwrite=T)
endCluster()

