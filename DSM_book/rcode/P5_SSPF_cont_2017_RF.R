# Random Forest modeling for digital soil mapping


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

## Fit random forest model
library(randomForest)
set.seed(123)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))

#fit the model
hv.RF.Exp <- randomForest(pH60_100cm ~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI, data = DSM_data[training, ], importance = TRUE, ntree = 1000)

# some summaries
print(hv.RF.Exp)
varImpPlot(hv.RF.Exp)

## Goodness of Fit
#Internal validation
RF.pred.C <- predict(hv.RF.Exp, newdata = DSM_data[training,])
goof(observed = DSM_data$pH60_100cm[training] , predicted = RF.pred.C )

#External validation
RF.pred.V <- predict(hv.RF.Exp, newdata = DSM_data[-training,])
goof(observed = DSM_data$pH60_100cm[-training] , predicted = RF.pred.V )

## Apply model spatially
map.RF.r1<- predict(hunterCovariates_sub,hv.RF.Exp, "soilpH_60_100_RF.tif",
             format = "GTiff", datatype = "FLT4S", overwrite = TRUE)

 plot(map.RF.r1,
      main = "Random Forest model predicted Hunter Valley soil pH (60-100cm)")


 
# END