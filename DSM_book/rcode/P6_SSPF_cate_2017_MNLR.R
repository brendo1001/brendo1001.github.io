## Multinomial logistic regression for digital soil mapping




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

## Multinomial logisitc regression model
library(nnet)

set.seed(655)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data))
hv.MNLR <- multinom(terron ~ AACN + Drainage.Index + Light.Insolation + TWI + Gamma.Total.Count, data = DSM_data[training, ])

## Model summaries
summary(hv.MNLR)
## 
#Estimate class probabilities
probs.hv.MNLR <- fitted(hv.MNLR)
 
#return top of data frame of probabilites
head(probs.hv.MNLR)

## model prediciton
pred.hv.MNLR <- predict(hv.MNLR)
summary(pred.hv.MNLR)

## goodness of fit (calibration)
goofcat(observed = DSM_data$terron[training] , predicted = pred.hv.MNLR )

## goodness of fit (validation)
V.pred.hv.MNLR <- predict(hv.MNLR, newdata = DSM_data[-training, ])
goofcat(observed = DSM_data$terron[-training] , predicted = V.pred.hv.MNLR )

## Apply model spatially
## #class prediction
map.MNLR.c<- predict(hunterCovariates, hv.MNLR, type="class",
              filename="hv_MNLR_class.tif",format="GTiff",
              overwrite=T, datatype="INT2S")
 
## #class probabilities
map.MNLR.p<- predict(hunterCovariates, hv.MNLR, type="probs",
              index = 1,filename="edge_MNLR_probs1.tif", format="GTiff",
              overwrite=T, datatype="FLT4S")

## Plotting
map.MNLR.c <- as.factor(map.MNLR.c)
 
## Add a land class column to the Raster Attribute Table
rat <- levels(map.MNLR.c)[[1]]
rat[["terron"]] <- c("HVT_001","HVT_002", "HVT_003","HVT_004","HVT_005","HVT_006", "HVT_007", "HVT_008", "HVT_009", "HVT_010", "HVT_011", "HVT_012")
levels(map.MNLR.c) <- rat
 
## HEX colors
area_colors <- c("#FF0000", "#38A800", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", "#FFA77F", "#7AF5CA", "#D7B09E", "#CCCCCC", "#B4D79E", "#FFFF00")
#plot
levelplot(map.MNLR.c, col.regions=area_colors, xlab="", ylab="")

