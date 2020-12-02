---
layout: page
title: C5 decision trees
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

The C5 decision tree model is available in the `C50` package. The
function `C5.0` fits classification tree models or rule-based models
using Quinlans’s C5.0 algorithm (Quinlan 1993).

Essentially we will go through the same process as we did for the
[multinomial logistic regression]({{ site.url }}/DSM_book/pages/dsm_cat/mlr/). The
`C5.0` function and its internal parameters are similar in nature to
that of the [`Cubist` function for predicting continuous variables]({{ site.url }}/DSM_book/pages/dsm_cont/sspfs/cubist/).
The `trials` parameter lets you implement a boosted classification tree
process, with the results aggregated at the end. There are also many
other useful model tuning parameters in the `C5.0Control` parameter set
too that are worth a look. Just see the help files for more information.

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

With the calibration data prepared, we will fit the C5 model as in the
script below.

```r
library(C50)
hv.C5 <- C5.0(x = DSM_data[training, c("AACN", "Drainage.Index", "Light.Insolation", 
    "TWI", "Gamma.Total.Count")], y = DSM_data$terron[training], trials = 1, rules = FALSE, 
    control = C5.0Control(CF = 0.95, minCases = 20, earlyStopping = FALSE))
```

By calling the `summary` function, some useful model fit diagnostics are
given. These include the tree structure, together with the covariates
used and mis-classification error of the model, as well as a rudimentary
confusion matrix. A useful feature of the C5 model is that it can omit
in an automated fashion, unnecessary covariates.

The `predict` function can either return the predicted class or the
confidence of the predictions (which is controlled using the
`type= prob` parameter. The probabilities are quantified such that if an
observation is classified by a single leaf of a decision tree, the
confidence value is the proportion of training cases at that leaf that
belong to the predicted class. If more than one leaf is involved (i.e.,
one or more of the attributes on the path has missing values), the value
is a weighted sum of the individual leaves’ confidences. For
rule-classifiers, each applicable rule votes for a class with the voting
weight being the rule’s confidence value. If the sum of the votes for
class C is W(C), then the predicted class P is chosen so that W(P) is
maximal, and the confidence is the greater of (1), the voting weight of
the most specific applicable rule for predicted class P; or (2) the
average vote for class P (so, W(P) divided by the number of applicable
rules for class P).Boosted classifiers are similar, but individual
classifiers vote for a class with weight equal to their confidence
value. Overall, the confidence associated with each class for every
observation are made to sum to 1.

```r
# return the class predictions [first 10 cases]
predict(hv.C5, newdata = DSM_data[training, ])[1:10]

##  [1] 3  8  8  5  3  5  8  6  8  12
## Levels: 1 2 3 4 5 6 7 8 9 10 11 12

# return the class probabilities [first 10 cases]
predict(hv.C5, newdata = DSM_data[training, ], type = "prob")[1:10, ]

##                1            2            3            4           5           6
## 366 0.0003479853 1.648352e-04 0.4500366339 0.0520695959 0.001684982 0.001227106
## 79  0.0001833977 8.687259e-05 0.0006949807 0.0274420842 0.122509653 0.047944016
## 946 0.0001833977 8.687259e-05 0.0006949807 0.0274420842 0.122509653 0.047944016
## 148 0.0003525046 1.669759e-04 0.0013358070 0.0007977737 0.573135431 0.027217069
## 710 0.0003479853 1.648352e-04 0.4500366339 0.0520695959 0.001684982 0.001227106
## 729 0.0007539682 3.571428e-04 0.0028571428 0.0017063492 0.503650805 0.419325387
## 848 0.0012925170 6.122449e-04 0.0048979592 0.0029251702 0.149115652 0.052176872
## 20  0.0005219780 2.472527e-04 0.0019780219 0.0011813187 0.060219780 0.809532966
## 923 0.0001833977 8.687259e-05 0.0006949807 0.0274420842 0.122509653 0.047944016
## 397 0.0354187203 4.433497e-04 0.0725123176 0.0366009864 0.039014779 0.003300493
##               7           8           9          10           11           12
## 366 0.168901096 0.014816850 0.077765564 0.000989011 0.1416300399 0.0903663012
## 79  0.176853281 0.426727801 0.020714285 0.095115831 0.0813996118 0.0003281853
## 946 0.176853281 0.426727801 0.020714285 0.095115831 0.0813996118 0.0003281853
## 148 0.002263451 0.053970316 0.169684604 0.169833027 0.0006122449 0.0006307978
## 710 0.168901096 0.014816850 0.077765564 0.000989011 0.1416300399 0.0903663012
## 729 0.004841270 0.004325397 0.029603174 0.029920634 0.0013095237 0.0013492063
## 848 0.008299320 0.340748295 0.050748300 0.337006798 0.0022448979 0.0499319738
## 20  0.003351648 0.079917584 0.001263736 0.020714286 0.0201373630 0.0009340660
## 923 0.176853281 0.426727801 0.020714285 0.095115831 0.0813996118 0.0003281853
## 397 0.074975372 0.005369458 0.002266010 0.347487689 0.0016256157 0.3809852094
```

<a href="#top">Back to top</a>

### Model goodness of fit <a id="s-4"></a>

So lets look at the calibration and validation statistics. First, the
calibration statistics:

```r
C.pred.hv.C5 <- predict(hv.C5, newdata = DSM_data[training, ])
goofcat(observed = DSM_data$terron[training], predicted = C.pred.hv.C5)

## $confusion_matrix
##     1 2  3  4  5  6  7  8  9 10 11 12
## 1  10 5  1  4  0  0  0  0  2  0  0  0
## 2   0 0  0  0  0  0  0  0  0  0  0  0
## 3   5 3 43  5  0  0 14  1  6  1 11  8
## 4   3 0 11 23  0  0  3  3 12  0  5  1
## 5   0 0  0  0 62 17  0  4 14 14  0  0
## 6   0 0  0  0  3 42  0  4  0  1  1  0
## 7   0 1 15  6  0  0 77 15  7  6  4 12
## 8   0 0  0  4 26  8 26 82  5 22 12  2
## 9   0 0  0  0  0  0  0  0  0  0  0  0
## 10  0 0  0  0  0  0  0  0  0  0  0  0
## 11  0 0  0  0  0  0  0  0  0  0  0  0
## 12  1 0  2  1  1  0  2  0  0 10  0 11
## 
## $overall_accuracy
## [1] 50
## 
## $producers_accuracy
##  1  2  3  4  5  6  7  8  9 10 11 12 
## 53  0 60 54 68 63 64 76  0  0  0 33 
## 
## $users_accuracy
##   1   2   3   4   5   6   7   8   9  10  11  12 
##  46 NaN  45  38  56  83  54  44 NaN NaN NaN  40 
## 
## $kappa
## [1] 0.4269877
```

It will be noticed that some of the Terron classes failed to be
predicted by the fitted model. For example Terron classes 2, 9, 11, and
12 were all predicted as being a different class. All observations of
Terron class 2 were predicted as Terron class 1. Doing the external
validation we return the following:

```r
V.pred.hv.C5 <- predict(hv.C5, newdata = DSM_data[-training, ])
goofcat(observed = DSM_data$terron[-training], predicted = V.pred.hv.C5)

## $confusion_matrix
##    1 2  3  4  5  6  7  8 9 10 11 12
## 1  7 2  0  0  0  0  0  0 1  0  0  0
## 2  0 0  0  0  0  0  0  0 0  0  0  0
## 3  1 1 15  3  0  0  3  0 3  1  4  3
## 4  0 1  3 19  0  1  1  2 4  0  2  0
## 5  0 0  0  0 23  6  1  2 4  1  0  0
## 6  0 0  0  0  5 15  0  4 1  0  0  0
## 7  0 0  7  5  1  0 36 11 2  4  4  4
## 8  0 0  0  5 11  3 11 22 5 13  5  2
## 9  0 0  0  0  0  0  0  0 0  0  0  0
## 10 0 0  0  0  0  0  0  0 0  0  0  0
## 11 0 0  0  0  0  0  0  0 0  0  0  0
## 12 0 0  2  0  0  0  1  0 0  5  0  2
## 
## $overall_accuracy
## [1] 47
## 
## $producers_accuracy
##  1  2  3  4  5  6  7  8  9 10 11 12 
## 88  0 56 60 58 60 68 54  0  0  0 19 
## 
## $users_accuracy
##   1   2   3   4   5   6   7   8   9  10  11  12 
##  70 NaN  45  58  63  60  49  29 NaN NaN NaN  20 
## 
## $kappa
## [1] 0.3859025
```

<a href="#top">Back to top</a>

### Apply model spatially <a id="s-5"></a>

And finally, creating the map derived from the `hv.C5` model using the
raster `predict` function. Note that the C5 model returned 0% producer’s
accuracy for Terron classes 2, 9, 11 and 12. These data account for only
a small proportion of the data set, and/or, they may be similar to other
existing Terron classes (based on the available predictive covariates).
Consequently, they did not feature in the `hv.C5` model and ultimately,
the final map.

```r
# class prediction
map.C5.c <- predict(covStack, hv.C5, type = "class", filename = "hv_C5_class.tif", 
    format = "GTiff", overwrite = T, datatype = "INT2S")

map.C5.c <- as.factor(map.C5.c)
rat <- levels(map.C5.c)[[1]]
rat[["terron"]] <- c("HVT_001", "HVT_003", "HVT_004", "HVT_005", "HVT_006", "HVT_007", 
    "HVT_008", "HVT_010")
levels(map.C5.c) <- rat

# plot
area_colors <- c("#FF0000", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", "#FFA77F", 
    "#7AF5CA", "#CCCCCC")
rasterVis::levelplot(map.C5.c, col.regions = area_colors, xlab = "", ylab = "")
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/c5.png" alt="rconsole">
    <figcaption> Hunter Valley Terron class map created using C5 decision tree model.</figcaption>
</figure>


<a href="#top">Back to top</a>

### References

Malone, B P, P Hughes, A B McBratney, and B Minsany. 2014. “A Model for
the Identification of Terrons in the Lower Hunter Valley, Australia.”
*Geoderma Regional* 1: 31–47.

Quinlan, J R. 1993. *C4.5: Programs for Machine Learning*. Morgan
Kaufmann, San Mateo, California.
