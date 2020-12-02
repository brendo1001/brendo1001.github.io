---
layout: page
title: Random forest modelling
description: "Categorical Variables"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-09-13
---


-   [Introduction](#s-1)
-   [Data preparation](#s-2)
-   [Model fitting](#s-3)
-   [Model goodness of fit](#s-4)
-   [Applying the model spatially](#s-5)

### Introduction <a id="s-1"></a>

Here we will take another look at the Random Forest, which you may be
familiar with now as this model type was examined during [the continuous variable prediction methods section]({{site.url}}/DSM_book/pages/dsm_cont/sspfs/rf/).
It can also be used for categorical variables. Some useful extractor
functions like `print` and `importance` give some useful information
about the model performance.

<a href="#top">Back to top</a>

### Data Preparation <a id="s-2"></a>

The data to be used for the following modelling exercises are Terron
classes as sampled from the map presented in Malone et al. (2014) .The
sample data contains 1000 entries of which there are 12 different Terron
classes. Before getting into the modeling, we first load in the data and
then perform the covariate layer intersection using the suite of
environmental variables contained in the `hunterCovariates` data object
in the `ithir` package. The small selection of covariates cover an area
of approximately 220*k**m*<sup>2</sup> at a spatial resolution of 25m.
They include those derived from a DEM: altitude above channel network
(AACN), solar light insolation and terrain wetness index (TWI). Gamma
radiometric data (total count) is also included together with a surface
that depicts soil drainage in form of a continuous index (ranging from 0
to 5). These 5 different covariate layers are stacked together via a
`rasterStack`.

```r
# libraries
library(ithir)
library(sp)
library(raster)

# load data
data(hvTerronDat)
data(hunterCovariates)
```

Transform the `hvTerronDat` data to a `SpatialPointsDataFrame`.

```r
names(hvTerronDat)

## [1] "x"      "y"      "terron"

coordinates(hvTerronDat) <- ~x + y
```

As these data are of the same spatial projection as the
`hunterCovariates`, there is no need to perform a coordinate
transformation. So we can perform the intersection immediately.

```r
DSM_data <- extract(hunterCovariates, hvTerronDat, sp = 1, method = "simple")
DSM_data <- as.data.frame(DSM_data)
str(DSM_data)

## 'data.frame':    1000 obs. of  8 variables:
##  $ x                : num  346535 334760 340910 336460 344510 ...
##  $ y                : num  6371940 6375840 6377690 6382040 6378116 ...
##  $ terron           : Factor w/ 12 levels "1","2","3","4",..: 3 4 12 5 6 11 3 10 3 5 ...
##  $ AACN             : num  37.544 25.564 32.865 0.605 9.516 ...
##  $ Drainage.Index   : num  4.72 4.78 2 4.19 4.68 ...
##  $ Light.Insolation : num  1690 1736 1712 1712 1677 ...
##  $ TWI              : num  11.5 13.8 13.4 18.6 19.8 ...
##  $ Gamma.Total.Count: num  380 407 384 388 454 ...
```

It is always good practice to check to see if any of the observational
data returned any `NA` values for any one of the covariates. If there is
`NA` values, it indicates that the observational data is outside the
extent of the covariate layers. It is best to remove these observations
from the data set.

```r
which(!complete.cases(DSM_data))

## integer(0)

DSM_data <- DSM_data[complete.cases(DSM_data), ]
```

We will also subset the data for an external validation i.e. random hold
back validation. Here 70% of the data for model calibration, leaving the
other 30% for validation.

```r
set.seed(655)

# create calibration/validation datasets
training <- sample(nrow(DSM_data), 0.7 * nrow(DSM_data))
```

<a href="#top">Back to top</a>

### Model fitting <a id="s-3"></a>

```r
library(randomForest)

## randomForest 4.6-14

## Type rfNews() to see new features/changes/bug fixes.

hv.RF <- randomForest(terron ~ AACN + Drainage.Index + Light.Insolation + TWI + Gamma.Total.Count, 
    data = DSM_data[training, ], ntree = 500, mtry = 5)
```

Some model summary diagnostics

```r
# Output random forest model diognostics
print(hv.RF)

## 
## Call:
##  randomForest(formula = terron ~ AACN + Drainage.Index + Light.Insolation +      TWI + Gamma.Total.Count, data = DSM_data[training, ], ntree = 500,      mtry = 5) 
##                Type of random forest: classification
##                      Number of trees: 500
## No. of variables tried at each split: 5
## 
##         OOB estimate of  error rate: 51.29%
## Confusion matrix:
##    1 2  3  4  5  6  7  8 9 10 11 12 class.error
## 1  4 3  2  7  0  0  0  0 3  0  0  0   0.7894737
## 2  4 1  2  1  0  0  0  0 1  0  0  0   0.8888889
## 3  1 0 39  7  0  0 17  0 0  0  3  5   0.4583333
## 4  6 1  6 16  0  0  6  2 4  0  1  1   0.6279070
## 5  0 0  1  1 56 14  3 11 0  4  2  0   0.3913043
## 6  0 0  0  0 10 48  0  8 0  1  0  0   0.2835821
## 7  0 0 15  3  3  0 75 16 1  3  2  4   0.3852459
## 8  0 0  0  4  8  5 18 63 1  5  5  0   0.4220183
## 9  2 0  4  5  9  0  7  4 7  3  5  0   0.8478261
## 10 1 0  0  0 11  2  7  9 0 19  2  3   0.6481481
## 11 0 0 12  1  2  1  3  8 2  1  1  2   0.9696970
## 12 0 0  3  0  1  0 14  0 0  3  1 12   0.6470588

# output relative importance of each covariate
importance(hv.RF)

##                   MeanDecreaseGini
## AACN                     116.97555
## Drainage.Index           127.87488
## Light.Insolation          85.14123
## TWI                      186.51138
## Gamma.Total.Count        104.81717
```

Three types of prediction outputs can be generated from Random Forest
models, and are specified via the `type` parameter of the `predict`
extractor functions. The different `types` are the `response` (predicted
class), `prob` (class probabilities) or `vote` (vote count, which really
just appears to return the probabilities).

```r
# Prediction of classes [first 10 cases]
predict(hv.RF, type = "response", newdata = DSM_data[training, ])[1:10]

## 366  79 946 148 710 729 848  20 923 397 
##  12   8   7   5   3   6   5   6  11   5 
## Levels: 1 2 3 4 5 6 7 8 9 10 11 12

# Class probabilities [first 10 cases]
predict(hv.RF, type = "prob", newdata = DSM_data[training, ])[1:10, ]

##         1     2     3     4     5     6     7     8     9    10    11    12
## 366 0.006 0.000 0.094 0.010 0.000 0.000 0.024 0.000 0.004 0.002 0.020 0.840
## 79  0.000 0.000 0.000 0.002 0.058 0.000 0.140 0.778 0.000 0.012 0.010 0.000
## 946 0.000 0.000 0.000 0.018 0.060 0.008 0.614 0.128 0.016 0.112 0.044 0.000
## 148 0.000 0.000 0.000 0.000 0.820 0.010 0.000 0.082 0.064 0.022 0.000 0.002
## 710 0.002 0.004 0.904 0.012 0.000 0.000 0.048 0.000 0.014 0.000 0.014 0.002
## 729 0.000 0.000 0.000 0.000 0.294 0.698 0.000 0.006 0.000 0.002 0.000 0.000
## 848 0.000 0.000 0.000 0.000 0.886 0.028 0.000 0.000 0.006 0.080 0.000 0.000
## 20  0.000 0.000 0.000 0.000 0.058 0.856 0.000 0.074 0.000 0.002 0.010 0.000
## 923 0.000 0.000 0.002 0.040 0.032 0.038 0.040 0.122 0.008 0.040 0.678 0.000
## 397 0.004 0.000 0.112 0.008 0.618 0.000 0.030 0.008 0.022 0.074 0.044 0.080
```

<a href="#top">Back to top</a>

### Model goodness of fit<a id="s-4"></a>

From the diagnostics output of the `hv.RF` model the confusion matrix is
automatically generated, except it was a different orientation to what
we have been looking for previous examples. This confusion matrix was
performed on what is called the OOB or out-of-bag data i.e. it validates
the model/s dynamically with observations withheld from the model fit.
So lets just evaluate the model as we have done for the previous models.
For calibration:

```r
C.pred.hv.RF <- predict(hv.RF, newdata = DSM_data[training, ])
goofcat(observed = DSM_data$terron[training], predicted = C.pred.hv.RF)

## $confusion_matrix
##     1 2  3  4  5  6   7   8  9 10 11 12
## 1  19 0  0  0  0  0   0   0  0  0  0  0
## 2   0 9  0  0  0  0   0   0  0  0  0  0
## 3   0 0 72  0  0  0   0   0  0  0  0  0
## 4   0 0  0 43  0  0   0   0  0  0  0  0
## 5   0 0  0  0 92  0   0   0  0  0  0  0
## 6   0 0  0  0  0 67   0   0  0  0  0  0
## 7   0 0  0  0  0  0 122   0  0  0  0  0
## 8   0 0  0  0  0  0   0 109  0  0  0  0
## 9   0 0  0  0  0  0   0   0 46  0  0  0
## 10  0 0  0  0  0  0   0   0  0 54  0  0
## 11  0 0  0  0  0  0   0   0  0  0 33  0
## 12  0 0  0  0  0  0   0   0  0  0  0 34
## 
## $overall_accuracy
## [1] 100
## 
## $producers_accuracy
##   1   2   3   4   5   6   7   8   9  10  11  12 
## 100 100 100 100 100 100 100 100 100 100 100 100 
## 
## $users_accuracy
##   1   2   3   4   5   6   7   8   9  10  11  12 
## 100 100 100 100 100 100 100 100 100 100 100 100 
## 
## $kappa
## [1] 1
```

It seems quite incredible that this particular model is indicating a
100% accuracy. Here it pays to look at the out-of-bag error of the
`hv.RF` model for a better indication of the model goodness of fit. For
the random holdback validation:

```r
V.pred.hv.RF <- predict(hv.RF, newdata = DSM_data[-training, ])
goofcat(observed = DSM_data$terron[-training], predicted = V.pred.hv.RF)

## $confusion_matrix
##    1 2  3 4  5  6  7  8 9 10 11 12
## 1  5 1  0 1  0  0  0  0 0  0  0  0
## 2  1 0  0 0  0  0  0  0 0  0  0  0
## 3  0 1 18 7  0  0  5  1 4  0  2  1
## 4  2 1  0 9  0  1  1  2 1  0  0  0
## 5  0 0  0 0 23  3  1  3 5  0  2  0
## 6  0 0  0 1  5 18  0  3 1  0  0  0
## 7  0 0  4 5  3  0 34  7 2  7  6  4
## 8  0 0  0 2  6  2  8 19 2  3  2  2
## 9  0 1  0 3  0  0  0  1 4  0  0  0
## 10 0 0  1 0  3  1  1  2 0 11  0  1
## 11 0 0  2 4  0  0  1  3 1  1  3  0
## 12 0 0  2 0  0  0  2  0 0  2  0  3
## 
## $overall_accuracy
## [1] 49
## 
## $producers_accuracy
##  1  2  3  4  5  6  7  8  9 10 11 12 
## 63  0 67 29 58 72 65 47 20 46 20 28 
## 
## $users_accuracy
##  1  2  3  4  5  6  7  8  9 10 11 12 
## 72  0 47 53 63 65 48 42 45 56 20 34 
## 
## $kappa
## [1] 0.4224744
```

So based on the model validation, the Random Forest performs quite
similarly to the other models that were used before, despite a *perfect*
performance based on the diagnostics of the calibration model.

<a href="#top">Back to top</a>

### Apply model spatially <a id="s-5"></a>

And finally the map that results from applying the `hv.RF` model to the
covariate rasters.

```r
# class prediction
map.RF.c <- predict(covStack, hv.RF, filename = "hv_RF_class.tif", format = "GTiff", 
    overwrite = T, datatype = "INT2S")

map.RF.c <- as.factor(map.RF.c)
rat <- levels(map.RF.c)[[1]]
rat[["terron"]] <- c("HVT_001", "HVT_002", "HVT_003", "HVT_004", "HVT_005", "HVT_006", 
    "HVT_007", "HVT_008", "HVT_009", "HVT_010", "HVT_011", "HVT_012")
levels(map.RF.c) <- rat

# plot
area_colors <- c("#FF0000", "#38A800", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", 
    "#FFA77F", "#7AF5CA", "#D7B09E", "#CCCCCC", "#B4D79E", "#FFFF00")
rasterVis::levelplot(map.RF.c, col.regions = area_colors, xlab = "", ylab = "")
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/CATrf.png" alt="rconsole">
    <figcaption> Hunter Valley Terron class map created using random forest model.</figcaption>
</figure>


<a href="#top">Back to top</a>

### References

Malone, B P, P Hughes, A B McBratney, and B Minsany. 2014. “A Model for
the Identification of Terrons in the Lower Hunter Valley, Australia.”
*Geoderma Regional* 1: 31–47.
