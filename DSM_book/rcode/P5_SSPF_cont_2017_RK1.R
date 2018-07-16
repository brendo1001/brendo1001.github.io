## Regression  

## libraries
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


## Calibration dataset
set.seed(123)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
cDat<- DSM_data[training, ]

coordinates(cDat)<- ~x+ y
crs(cDat)<- "+proj=utm +zone=56 +south +ellps=WGS84 + datum=WGS84 +units=m +no_defs"
crs(hunterCovariates_sub)= crs(cDat)

#check
crs(cDat)
crs(hunterCovariates_sub)



## Variogram 
library(gstat)
vgm1 <- variogram(pH60_100cm~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI, cDat, width = 200, cutoff = 3000)
mod<-vgm(psill= var(cDat$pH60_100cm), "Exp", range= 3000, nugget = 0) 
model_1 <- fit.variogram(vgm1, mod)
model_1

# Universal kriging model
gUK <- gstat(NULL, "pH", pH60_100cm ~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI, cDat, model=model_1)

## Validation dataset
vDat<- DSM_data[-training,]
coordinates(vDat)<- ~x+ y
crs(vDat)<- "+proj=utm +zone=56 +south +ellps=WGS84 + datum=WGS84 +units=m +no_defs"
crs(vDat)

#make the predictions
UK.preds.V<- as.data.frame(krige(pH60_100cm ~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI, cDat, model=model_1, newdata= vDat))

# goodness of fit (validation data)
goof(observed = DSM_data$pH60_100cm[-training] , predicted = UK.preds.V[,3])

## Apply model spatially
par(mfrow = c(1, 2))
## #predictions
UK.P.map <- interpolate(hunterCovariates_sub, gUK, xyOnly=FALSE, index = 1)
plot(UK.P.map, main= "Universal kriging predictions")
## 
## #prediction variance
UK.Pvar.map <- interpolate(hunterCovariates_sub, gUK, xyOnly=FALSE, index = 2)
plot(UK.Pvar.map, main = "Universal kriging prediction variance")


## END
