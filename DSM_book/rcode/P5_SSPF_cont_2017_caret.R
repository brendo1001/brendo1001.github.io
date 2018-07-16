## Som brief introduction to harnessing the R Caret package for digital soil mapping

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



## Begin the Caret 
library(caret)

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
pred_cubistMap <- predict(hunterCovariates_sub, fit_cubist)


##END



