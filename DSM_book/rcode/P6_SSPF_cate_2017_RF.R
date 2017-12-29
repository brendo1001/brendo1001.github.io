## Using the random forest model for categorical attributes



## Get data
library(ithir)
library(sp)
library(raster)
library(rasterVis)

data(hvTerronDat)
data(hunterCovariates)

## coerce data to spatial object
names(hvTerronDat)
coordinates(hvTerronDat) <- ~ x + y

## Covariate data extraction
DSM_data<- extract(hunterCovariates,hvTerronDat, sp= 1, method = "simple")
DSM_data<- as.data.frame(DSM_data)
str(DSM_data)

## remove missing data
which(!complete.cases(DSM_data))
DSM_data<- DSM_data[complete.cases(DSM_data),]

## Random holdback
set.seed(655)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))


## Fit model
library(randomForest)

hv.RF <- randomForest(terron ~ AACN + Drainage.Index + Light.Insolation + TWI + Gamma.Total.Count, data = DSM_data[training, ], ntree = 500, mtry = 5)


#Output random forest model diognostics
print(hv.RF)

#output relative importance of each covariate
importance(hv.RF)


#Prediction of classes
predict(hv.RF, type = "response", newdata = DSM_data[training, ])

#Class probabilities
predict(hv.RF, type = "prob", newdata = DSM_data[training, ])

# Goodness of fit calibration 
C.pred.hv.RF <- predict(hv.RF, newdata = DSM_data[training, ])
goofcat(observed = DSM_data$terron[training] , predicted = C.pred.hv.RF )

## Goodness of fit validation
V.pred.hv.RF <- predict(hv.RF, newdata = DSM_data[-training, ])
goofcat(observed = DSM_data$terron[-training] , predicted = V.pred.hv.RF )

## Apply model spatially
## #class prediction
map.RF.c<- predict(covStack, hv.RF,filename="hv_RF_class.tif",format="GTiff",overwrite=T, datatype="INT2S")

## plotting
map.RF.c <- as.factor(map.RF.c)
rat <- levels(map.RF.c)[[1]]
rat[["terron"]] <- c("HVT_001","HVT_002", "HVT_003","HVT_004","HVT_005","HVT_006", "HVT_007", "HVT_008", "HVT_009", "HVT_010", "HVT_011", "HVT_012")
levels(map.RF.c) <- rat

#plot
area_colors <- c("#FF0000", "#38A800", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", "#FFA77F", "#7AF5CA", "#D7B09E", "#CCCCCC", "#B4D79E", "#FFFF00")
levelplot(map.RF.c, col.regions=area_colors, xlab="", ylab="")

