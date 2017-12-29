## C5 Modeling for digital soil mapping


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
library(C50)
hv.C5 <- C5.0(x = DSM_data[training, c("AACN" , "Drainage.Index" , "Light.Insolation" , "TWI" , "Gamma.Total.Count")],
                y = DSM_data$terron[training], trials = 1, rules = FALSE, control = C5.0Control(CF = 0.95, minCases = 20, earlyStopping = FALSE))


#return the class predictions
predict(hv.C5, newdata = DSM_data[training, ])
 
#return the class probabilities
predict(hv.C5, newdata = DSM_data[training, ], type = "prob")

## Goodness of fit calibration data
C.pred.hv.C5 <- predict(hv.C5, newdata = DSM_data[training, ])
goofcat(observed = DSM_data$terron[training] , predicted = C.pred.hv.C5 )

## Goodness of fit validation data
V.pred.hv.C5 <- predict(hv.C5, newdata = DSM_data[-training, ])
goofcat(observed = DSM_data$terron[-training] , predicted = V.pred.hv.C5 )

## Applying model spatially
#class prediction
map.C5.c<- predict(hunterCovariates, hv.C5, type="class",filename="hv_C5_class.tif",format="GTiff",overwrite=T, datatype="INT2S")
 
map.C5.c <- as.factor(map.C5.c)
rat <- levels(map.C5.c)[[1]]
rat[["terron"]] <- c("HVT_001", "HVT_003","HVT_004","HVT_005","HVT_006", "HVT_007", "HVT_008", "HVT_010")
levels(map.C5.c) <- rat
 
#plot
area_colors <- c("#FF0000", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", "#FFA77F", "#7AF5CA", "#CCCCCC")
levelplot(map.C5.c, col.regions=area_colors, xlab="", ylab="")

