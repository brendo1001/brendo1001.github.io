## Regression Kriging. 
## Cubist modeling of environmental trend followed by variogram model of cubist model residuals 

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


## Cubist modeling of environmental trend
library(Cubist)
set.seed(875)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
mDat <- DSM_data[training, ]

#fit the model
hv.cub.Exp <- cubist(x = mDat[, c("AACN", "Landsat_Band1", "Elevation",
              "Hillshading", "Mid_Slope_Positon", "MRVBF", "NDVI", 
              "TWI")], y = mDat$pH60_100cm, 
              cubistControl(rules = 100, extrapolation = 15), committees = 1)

## Model residuals
mDat$residual <- mDat$pH60_100cm - predict(hv.cub.Exp, newdata = mDat)
mean(mDat$residual)

## Variogram
coordinates(mDat)<- ~x+ y
crs(mDat)<- "+proj=utm +zone=56 +south +ellps=WGS84 
             + datum=WGS84 +units=m +no_defs"

vgm1 <- variogram(residual~1, mDat, width = 200, cutoff = 3000)
mod<-vgm(psill= var(mDat$residual), "Sph", range= 3000, nugget = 0) 
model_1 <- fit.variogram(vgm1, mod)
model_1

# Residual kriging model
gRK <- gstat(NULL, "RKresidual", residual~1, mDat, model=model_1)

## Model Validation
#Cubist model only
Cubist.pred.V <- predict(hv.cub.Exp, newdata = DSM_data[-training,])

#Cubist model with residual variogram
vDat<- DSM_data[-training,]
coordinates(vDat)<- ~x+ y
crs(vDat)<- "+proj=utm +zone=56 +south +ellps=WGS84 + datum=WGS84 +units=m +no_defs"

#make the residual predictions
RK.preds.V<- as.data.frame(krige(residual~1, mDat, model=model_1, newdata= vDat))

#Sum the two components together
RK.preds.fin<- Cubist.pred.V + RK.preds.V[,3]

#validation cubist only
goof(observed = DSM_data$pH60_100cm[-training] , predicted = Cubist.pred.V )

#validation regression kriging with cubist model
goof(observed = DSM_data$pH60_100cm[-training] , predicted = RK.preds.fin)

## Spatial prediction
par(mfrow = c(3, 1))

# Cubist model
map.RK1<- predict(hunterCovariates_sub,hv.cub.Exp,
          filename = "soilpH_60_100_cubistRK.tif",format = "GTiff",
          datatype = "FLT4S", overwrite = TRUE  )
 plot(map.RK1, main = "Cubist model predicted soil pH")

## Interpolated residuals 
map.RK2<- interpolate(hunterCovariates_sub, gRK, xyOnly=TRUE,
           index = 1, filename = "soilpH_60_100_residualRK.tif",
           format = "GTiff", datatype = "FLT4S", overwrite = TRUE)
 plot(map.RK2, main = "Kriged residual")

 
## Sum of cubist predictions and residuals 
## #Stack prediction and kriged residuals
pred.stack<- stack(map.RK1, map.RK2)
 
map.RK3 <- calc(pred.stack, fun=sum, filename="soilpH_60_100_finalPredRK.tif",
           format="GTiff",progress="text",overwrite=T)
plot(map.RK3, main = "Regression kriging prediction")


## END



