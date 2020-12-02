---
layout: page
title: Multinomial logistic regression
description: "Categorical Variables"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-09-06
---

-   [Introduction](#s-1)
-   [Data preparation](#s-2)
-   [Model fitting](#s-3)
-   [Model goodness of fit](#s-4)
-   [Applying the model spatially](#s-5)

### Introduction <a id="s-1"></a>

Multinomial logistic regression is used to model nominal outcome
variables, in which the log odds of the outcomes are modeled as a linear
combination of the predictor variables. Because we are dealing with
categorical variables, it is necessary that logistic regression take the
natural logarithm of the odds (log-odds) to create a continuous
criterion. The logit of success is then fit to the predictors using
regression analysis. The results of the logit, however are not
intuitive, so the logit is converted back to the odds via the inverse of
the natural logarithm, namely the exponential function. Therefore,
although the observed variables in logistic regression are categorical,
the predicted scores are modeled as a continuous variable (the logit).
The logit is referred to as the link function in logistic regression. As
such, although the output in logistic regression will be binomial or
multinomial, the logit is an underlying continuous criterion upon which
linear regression is conducted. This means that for logistic regression
we are able to return the most likely or probable prediction (class) as
well as the probabilities of occurrence for all the other classes
considered. Some discussion of the theoretical underpinnings of
multinomial logistic regression, and importantly its application in DSM
is given in Kempen et al. (2009).

<a href="#top">Back to top</a>

### Data Preparation <a id="s-2"></a>

In `R` we can use the `multinom` function from the package to perform
logistic regression. The are other implementations of this model in `R`,
so it is worth a look to compare and contrast them. Fitting `multinom`
is just like fitting a linear model as seen below.

As described earlier, the data to be used for the following modelling
exercises are Terron classes as sampled from the map presented in Malone et al. (2014). The sample data contains 1000 entries of which there are 12 different Terron
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

<a href="#top">Back to top</a>

### Model Fitting <a id="s-3"></a>

Now for model fitting. The target variable is `terron`. So lets just use
all the available covariates in the model. We will also subset the data
for an external validation i.e. random hold back validation.

```r
library(nnet)

set.seed(655)

# create calibration/validation datasets
training <- sample(nrow(DSM_data), 0.7 * nrow(DSM_data))

# fit model
hv.MNLR <- multinom(terron ~ AACN + Drainage.Index + Light.Insolation + TWI + Gamma.Total.Count, 
    data = DSM_data[training, ])

## # weights:  84 (66 variable)
## initial  value 1739.434655 
## iter  10 value 1531.379550
## iter  20 value 1318.727793
## iter  30 value 1169.187982
## iter  40 value 1123.401146
## iter  50 value 1064.839291
## iter  60 value 1014.089905
## iter  70 value 1000.822814
## iter  80 value 998.380342
## iter  90 value 998.152674
## iter 100 value 998.091135
## final  value 998.091135 
## stopped after 100 iterations
```

Using the `summary` function allows us to see the linear models for each
Terron class, which are the result of the log-odds of each soil class
modeled as a linear combination of the covariates. We can also see the
probabilities of occurrence for each Terron class at each observation
location by using the `fitted` function.

```r
summary(hv.MNLR)

## Call:
## multinom(formula = terron ~ AACN + Drainage.Index + Light.Insolation + 
##     TWI + Gamma.Total.Count, data = DSM_data[training, ])
## 
## Coefficients:
##    (Intercept)          AACN Drainage.Index Light.Insolation        TWI
## 2    11.669249 -4.402383e-05     -0.1488482    -0.0031018687 -0.8238904
## 3    -9.411251  1.710763e-02     -1.1871127    -0.0014710974  1.4325870
## 4    -9.555444  4.395081e-02     -0.1447566    -0.0089310555  2.2511475
## 5    -7.588070 -1.581112e-01     -1.1950854    -0.0083953051  2.9494259
## 6    -4.098643 -1.471366e-03     -1.7886604    -0.0223878916  4.2491592
## 7   -11.260912 -7.417858e-02     -0.6580254    -0.0026478809  1.7317132
## 8    -3.446144 -7.091427e-02     -0.8835113    -0.0137537508  2.8020175
## 9    11.563466 -1.360664e-01     -1.0174030    -0.0123097556  2.3863682
## 10    5.358026 -1.945736e-01     -2.5210132    -0.0090684586  2.2443137
## 11   -9.500032  9.593433e-04     -1.3959474    -0.0073965218  2.5385508
## 12   -2.288478 -1.484163e-01     -2.3056330    -0.0008614319  1.4221890
##    Gamma.Total.Count
## 2       6.830734e-03
## 3       9.959415e-03
## 4      -8.281095e-05
## 5      -1.028384e-02
## 6      -1.801399e-02
## 7       1.260509e-02
## 8       3.094369e-03
## 9      -2.288428e-02
## 10      2.271286e-03
## 11      1.803500e-04
## 12      1.048366e-02
## 
## Std. Errors:
##     (Intercept)       AACN Drainage.Index Light.Insolation        TWI
## 2  0.0230014052 0.02737008      0.3502874      0.002154792 0.27516811
## 3  0.0019499214 0.02594060      0.1651929      0.001423865 0.12219279
## 4  0.0062391081 0.02540618      0.2849183      0.001711660 0.13477836
## 5  0.0014165140 0.03815983      0.2062900      0.002185650 0.10932725
## 6  0.0011020125 0.04250974      0.2735444      0.003346034 0.20085200
## 7  0.0018355164 0.03139042      0.1742066      0.001691151 0.09259951
## 8  0.0015169457 0.03324136      0.1811058      0.001961972 0.09167912
## 9  0.0059906322 0.02988414      0.2262947      0.001674441 0.10598892
## 10 0.0011730168 0.03959290      0.1780016      0.002102444 0.11480475
## 11 0.0008357622 0.03592314      0.2088213      0.002129659 0.12492035
## 12 0.0014626930 0.03982625      0.2041660      0.002081958 0.15271225
##    Gamma.Total.Count
## 2        0.006510157
## 3        0.004727097
## 4        0.005196532
## 5        0.006399191
## 6        0.006855861
## 7        0.005422967
## 8        0.005821308
## 9        0.005104764
## 10       0.006551655
## 11       0.006130347
## 12       0.006608973
## 
## Residual Deviance: 1996.182 
## AIC: 2128.182

# Estimate class probabilities
probs.hv.MNLR <- fitted(hv.MNLR)

# return top of data frame of probabilites
head(probs.hv.MNLR)

##                1            2            3           4            5
## 366 9.911578e-04 1.696907e-04 2.683064e-01 0.010060748 0.0042395682
## 79  1.991212e-06 4.378883e-08 1.857817e-02 0.034326492 0.0596735637
## 946 2.510423e-06 5.430068e-08 9.617759e-03 0.009881164 0.1406014006
## 148 7.962345e-11 9.274241e-14 5.488134e-05 0.001206554 0.4698120445
## 710 6.385443e-02 2.163694e-02 5.425491e-01 0.134304447 0.0002349476
## 729 3.926345e-12 2.428915e-15 1.068927e-05 0.000366097 0.4077434585
##                6           7           8          9           10          11
## 366 2.046389e-05 0.129056979 0.008636167 0.05272048 0.0736465603 0.051726811
## 79  9.467371e-04 0.366029678 0.366723926 0.03168955 0.0464104632 0.054306315
## 946 3.518185e-04 0.290060050 0.203745840 0.10754525 0.1534405545 0.027082347
## 148 8.424421e-02 0.008192209 0.339027028 0.04156585 0.0451892210 0.010102488
## 710 1.182175e-06 0.189834681 0.004335628 0.01035719 0.0003921219 0.022439213
## 729 3.231160e-01 0.001542456 0.200775080 0.02854113 0.0317291180 0.006003031
##               12
## 366 0.4004249213
## 79  0.0213130685
## 946 0.0576712560
## 148 0.0006055193
## 710 0.0100601340
## 729 0.0001729464
```

Subsequently, we can also determine the most probable Terron class using
the `predict` function.

```r
pred.hv.MNLR <- predict(hv.MNLR)
summary(pred.hv.MNLR)

##   1   2   3   4   5   6   7   8   9  10  11  12 
##  20   4  79  39 105  71 174 117  23  37   5  26
```
<a href="#top">Back to top</a>

### Model goodness of fit <a id="s-4"></a>

Lets now perform an internal validation of the model to assess its
general performance. Here we use the `goofcat` function that was
[introduced
earlier](%7B%7B%20site.url%20%7D%7D/DSM_book/pages/dsm_cat/val/), but
this time we import the two vectors into the function which correspond
to the observations and predictions respectively.

```r
goofcat(observed = DSM_data$terron[training], predicted = pred.hv.MNLR)

## $confusion_matrix
##     1 2  3  4  5  6  7  8  9 10 11 12
## 1  10 4  2  3  0  0  0  0  1  0  0  0
## 2   2 0  0  0  0  0  0  0  1  1  0  0
## 3   2 4 41  5  0  0 12  0  3  0  8  4
## 4   4 1  7 17  0  0  2  1  5  0  2  0
## 5   0 0  0  0 53 13  0 11 10 15  1  2
## 6   0 0  0  0 15 47  0  8  0  1  0  0
## 7   0 0 20  9  3  0 87 20  7  9  6 13
## 8   0 0  0  2 15  6 14 59  4  7 10  0
## 9   0 0  1  5  1  0  1  4  9  0  2  0
## 10  0 0  0  0  5  1  4  4  6 15  2  0
## 11  0 0  0  1  0  0  0  2  0  0  2  0
## 12  1 0  1  1  0  0  2  0  0  6  0 15
## 
## $overall_accuracy
## [1] 51
## 
## $producers_accuracy
##  1  2  3  4  5  6  7  8  9 10 11 12 
## 53  0 57 40 58 71 72 55 20 28  7 45 
## 
## $users_accuracy
##  1  2  3  4  5  6  7  8  9 10 11 12 
## 50  0 52 44 51 67 50 51 40 41 40 58 
## 
## $kappa
## [1] 0.4380009
```

Similarly, performing the external validation requires first using the
`pred.hv.MNLR` model to predict on the withheld points.

```r
V.pred.hv.MNLR <- predict(hv.MNLR, newdata = DSM_data[-training, ])
goofcat(observed = DSM_data$terron[-training], predicted = V.pred.hv.MNLR)

## $confusion_matrix
##    1 2  3 4  5  6  7  8 9 10 11 12
## 1  5 1  0 0  0  0  0  0 1  0  0  0
## 2  1 0  0 0  0  0  0  0 0  0  0  0
## 3  0 1 17 6  0  0  3  0 1  2  1  1
## 4  2 2  0 9  0  1  0  2 3  0  2  0
## 5  0 0  0 0 21  3  2  3 7  1  0  1
## 6  0 0  0 2  9 19  0  3 1  1  0  0
## 7  0 0  5 8  1  0 43 10 4  6  7  5
## 8  0 0  1 2  6  2  3 18 1  5  5  1
## 9  0 0  0 3  1  0  0  0 2  0  0  0
## 10 0 0  0 0  2  0  1  5 0  8  0  0
## 11 0 0  3 2  0  0  1  0 0  0  0  0
## 12 0 0  1 0  0  0  0  0 0  1  0  3
## 
## $overall_accuracy
## [1] 49
## 
## $producers_accuracy
##  1  2  3  4  5  6  7  8  9 10 11 12 
## 63  0 63 29 53 76 82 44 10 34  0 28 
## 
## $users_accuracy
##  1  2  3  4  5  6  7  8  9 10 11 12 
## 72  0 54 43 56 55 49 41 34 50  0 60 
## 
## $kappa
## [1] 0.4101904
```

<a href="#top">Back to top</a>

### Apply model spatially <a id="s-5"></a>

Using the raster `predict` function is the method for applying the
`hv.MNLR` model across the whole area. Note that the `clusterR` function
can also be used here too if there is a requirement to perform the
spatial prediction across multiple compute nodes. Note also that it is
also possible for multinomial logistic regression to create the map of
the most probable class, as well as the probabilities for all classes.
The first script example below is for mapping the most probable class
which is specified by setting the `type` parameter to `class`. If
probabilities are required `probs` would be used for the `type`
parameter, together with specifying an `index` integer to indicate which
class probabilities you wish to map. The second script example below
shows the parametisation for predicting the probabilities for Terron
class 1.

```r
# class prediction
map.MNLR.c <- predict(covStack, hv.MNLR, type = "class", filename = "hv_MNLR_class.tif", 
    format = "GTiff", overwrite = T, datatype = "INT2S")

# class probabilities
map.MNLR.p <- predict(covStack, hv.MNLR, type = "probs", index = 1, filename = "edge_MNLR_probs1.tif", 
    format = "GTiff", overwrite = T, datatype = "FLT4S")
```

Plotting the resulting class map is not as straightforward as for
mapping continuous variables. A solution is scripted below which uses an
associated package to `raster` called `rasterVis`. You will also note
the use of explicit colors for each Terron class as they were the same
colors used in the Terron map presented by Malone et al. (2014). The
colors are defined in terms of HEX color codes. A very good resource for
selecting colors or deciding on color ramps for maps is
[`colorbrewer`](https://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3).

```r
library(rasterVis)

map.MNLR.c <- as.factor(map.MNLR.c)

## Add a land class column to the Raster Attribute Table
rat <- levels(map.MNLR.c)[[1]]
rat[["terron"]] <- c("HVT_001", "HVT_002", "HVT_003", "HVT_004", "HVT_005", "HVT_006", 
    "HVT_007", "HVT_008", "HVT_009", "HVT_010", "HVT_011", "HVT_012")
levels(map.MNLR.c) <- rat

## HEX colors
area_colors <- c("#FF0000", "#38A800", "#73DFFF", "#FFEBAF", "#A8A800", "#0070FF", 
    "#FFA77F", "#7AF5CA", "#D7B09E", "#CCCCCC", "#B4D79E", "#FFFF00")

# plot
levelplot(map.MNLR.c, col.regions = area_colors, xlab = "", ylab = "")
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/mnlr.png" alt="rconsole">
    <figcaption> Hunter Valley most probable Terron class map created using multinomial logistic regression model.</figcaption>
</figure>


<a href="#top">Back to top</a>

### References

Kempen, B, D. J Brus, G. B. M Heuvelink, and J. J Stoorvogel. 2009.
“Updating the 1:50,000 Dutch Soil Map Using Legacy Soil Data: A
Multinomial Logistic Regression Approach.” *Geoderma* 151: 311–26.

Malone, B P, P Hughes, A B McBratney, and B Minsany. 2014. “A Model for
the Identification of Terrons in the Lower Hunter Valley, Australia.”
*Geoderma Regional* 1: 31–47.

<a href="#top">Back to top</a>
