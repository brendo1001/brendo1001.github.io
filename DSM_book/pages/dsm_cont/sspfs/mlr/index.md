---
layout: page
title: Multiple Linear Regression
description: "Continuous Variables"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-07-28
---

-   [Introduction](#s-1)
-   [Data preparation](#s-2)
-   [Perform the covariate intersection](#s-3)
-   [Model fitting (full model)](#s-4)
-   [Model fitting (step-wise covariate selection)](#s-5)
-   [Cross-validation](#s-6)
-   [Applying the model spatially](#s-7)
-   [Other possible spatial predictions (prediction intervals)](#s-8)

### Introduction <a id="s-1"></a>

Multiple linear regression (MLR) is where we regress a target variable
against more than one covariate. In terms of soil spatial prediction
functions, MLR is a least-squares model whereby we want to to predict a
continuous soil variable from a suite of covariates. There are a couple
of ways to go about this. We could just put everything (all the
covariates) in the model and then fit it (estimate the model
parameters). We could perform a step-wise regression model where we only
enter variables that are statistically significant, based on some
selection criteria. Alternatively we could fit what could be termed, an
‘expert’ model, such that based on some pre-determined knowledge of the
soil variable we are trying to model, we include covariates that best
describe this knowledge. In some ways this is a biased model because we
really don’t know everything about (the spatial characteristics) the
soil property under investigation. Yet in many situations it is better
to rely on expert knowledge that is gained in the field as opposed to
some other form.

<a href="#top">Back to top</a>

### Data preparation <a id="s-2"></a>

So lets firstly get the data organized. Recall from before in the [data
preparatory
exercises]({{ site.url }}/DSM_book/pages/dsm_prep/processes/)
that we were working with the soil point data and environmental
covariates for the Hunter Valley area. These data are stored in the
`HV_subsoilpH` and `hunterCovariates_sub` objects from the `ithir`
package. For the succession of models examined in these various pages,
we will concentrate on modelling and mapping the soil pH for the
60-100cm depth interval. To refresh, lets load the data in, then
intersect the data with the available covariates.

```r
library(ithir)
library(raster)

## Loading required package: sp

library(rgdal)

## rgdal: version: 1.4-8, (SVN revision 845)
##  Geospatial Data Abstraction Library extensions to R successfully loaded
##  Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
##  Path to GDAL shared files: /usr/share/gdal/2.2
##  GDAL binary built with GEOS: TRUE 
##  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
##  Path to PROJ.4 shared files: (autodetected)
##  Linking to sp version: 1.3-2

library(sp)

# point data
data(HV_subsoilpH)

# Start afresh round pH data to 2 decimal places
HV_subsoilpH$pH60_100cm <- round(HV_subsoilpH$pH60_100cm, 2)

# remove already intersected data
HV_subsoilpH <- HV_subsoilpH[, 1:3]

# add an id column
HV_subsoilpH$id <- seq(1, nrow(HV_subsoilpH), by = 1)

# re-arrange order of columns
HV_subsoilpH <- HV_subsoilpH[, c(4, 1, 2, 3)]

# Change names of coordinate columns
names(HV_subsoilpH)[2:3] <- c("x", "y")

# grids (covariate raster)
data(hunterCovariates_sub)
```

<a href="#top">Back to top</a>

#### Perform the covariate intersection <a id="s-1"></a>

```r
coordinates(HV_subsoilpH) <- ~x + y

# extract
DSM_data <- extract(hunterCovariates_sub, HV_subsoilpH, sp = 1, method = "simple")
DSM_data <- as.data.frame(DSM_data)
str(DSM_data)

## 'data.frame':    506 obs. of  15 variables:
##  $ id                      : num  1 2 3 4 5 6 7 8 9 10 ...
##  $ x                       : num  340386 340345 340559 340483 340734 ...
##  $ y                       : num  6368690 6368491 6369168 6368740 6368964 ...
##  $ pH60_100cm              : num  4.47 5.42 6.26 8.03 8.86 7.28 4.95 5.61 5.39 3.44 ...
##  $ Terrain_Ruggedness_Index: num  1.34 1.42 1.64 1.04 1.27 ...
##  $ AACN                    : num  1.619 0.281 2.301 1.74 3.114 ...
##  $ Landsat_Band1           : num  57 47 59 52 62 53 47 52 53 63 ...
##  $ Elevation               : num  103.1 103.7 99.9 101.9 99.8 ...
##  $ Hillshading             : num  1.849 1.428 0.934 1.517 1.652 ...
##  $ Light_insolation        : num  1689 1701 1722 1688 1735 ...
##  $ Mid_Slope_Positon       : num  0.876 0.914 0.844 0.848 0.833 ...
##  $ MRVBF                   : num  3.85 3.31 3.66 3.92 3.89 ...
##  $ NDVI                    : num  -0.143 -0.386 -0.197 -0.14 -0.15 ...
##  $ TWI                     : num  17.5 18.2 18.8 18 17.8 ...
##  $ Slope                   : num  1.79 1.42 1.01 1.49 1.83 ...
```

Often it is handy to check to see whether there are missing values both
in the target variable and of the covariates. It is possible that a
point location does not fit within the extent of the available
covariates. In these cases the data should be excluded. A quick way to
assess whether there are missing or `NA` values in the data is to use
the `complete.cases` function.

```r
which(!complete.cases(DSM_data))

## integer(0)

DSM_data <- DSM_data[complete.cases(DSM_data), ]
```

There do not appear to be any missing data as indicated by the
`integer(0)` output above i.e there are zero rows with missing
information.

<a href="#top">Back to top</a>

### Model fitting (full model) <a id="s-4"></a>

With the soil point data prepared, lets fit a model with everything in
it (all covariates) to get an idea of how to parameterise the MLR models
in `R`. Remember the soil variable we are making a model for is soil pH
for the 60-100cm depth interval.

```r
hv.MLR.Full <- lm(pH60_100cm ~ +Terrain_Ruggedness_Index + AACN + Landsat_Band1 + 
    Elevation + Hillshading + Light_insolation + Mid_Slope_Positon + MRVBF + NDVI + 
    TWI + Slope, data = DSM_data)
summary(hv.MLR.Full)

## 
## Call:
## lm(formula = pH60_100cm ~ +Terrain_Ruggedness_Index + AACN + 
##     Landsat_Band1 + Elevation + Hillshading + Light_insolation + 
##     Mid_Slope_Positon + MRVBF + NDVI + TWI + Slope, data = DSM_data)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -3.2380 -0.7843 -0.1225  0.7057  3.4641 
## 
## Coefficients:
##                           Estimate Std. Error t value Pr(>|t|)    
## (Intercept)               5.372452   2.147673   2.502 0.012689 *  
## Terrain_Ruggedness_Index  0.075084   0.054893   1.368 0.171991    
## AACN                      0.034747   0.007241   4.798 2.12e-06 ***
## Landsat_Band1            -0.037712   0.009355  -4.031 6.42e-05 ***
## Elevation                -0.013535   0.005550  -2.439 0.015079 *  
## Hillshading               0.152819   0.053655   2.848 0.004580 ** 
## Light_insolation          0.001329   0.001178   1.127 0.260081    
## Mid_Slope_Positon         0.928823   0.268625   3.458 0.000592 ***
## MRVBF                     0.324041   0.084942   3.815 0.000154 ***
## NDVI                      4.982413   0.887322   5.615 3.28e-08 ***
## TWI                       0.085150   0.045976   1.852 0.064615 .  
## Slope                    -0.102262   0.062391  -1.639 0.101838    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 1.178 on 494 degrees of freedom
## Multiple R-squared:  0.2501, Adjusted R-squared:  0.2334 
## F-statistic: 14.97 on 11 and 494 DF,  p-value: < 2.2e-16
```

<a href="#top">Back to top</a>

### Model fitting (step-wise covariate selection) <a id="s-5"></a>

From the summary output above, it seems a few of the covariates are
significant in describing the spatial variation of the target variable.
To determine the most parsimonious model we could perform a step-wise
regression using the `step` function. With this function we can also
specify what direction we want step wise algorithm to proceed.

```r
hv.MLR.Step <- step(hv.MLR.Full, trace = 0, direction = "both")
summary(hv.MLR.Step)

## 
## Call:
## lm(formula = pH60_100cm ~ AACN + Landsat_Band1 + Elevation + 
##     Hillshading + Mid_Slope_Positon + MRVBF + NDVI + TWI, data = DSM_data)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -3.1202 -0.8055 -0.1286  0.7443  3.4407 
## 
## Coefficients:
##                    Estimate Std. Error t value Pr(>|t|)    
## (Intercept)        7.449369   0.930288   8.008 8.36e-15 ***
## AACN               0.037413   0.006986   5.356 1.31e-07 ***
## Landsat_Band1     -0.037795   0.009134  -4.138 4.12e-05 ***
## Elevation         -0.012042   0.005299  -2.273 0.023481 *  
## Hillshading        0.089275   0.018576   4.806 2.04e-06 ***
## Mid_Slope_Positon  0.982066   0.263538   3.726 0.000216 ***
## MRVBF              0.307179   0.083361   3.685 0.000254 ***
## NDVI               5.111642   0.882036   5.795 1.21e-08 ***
## TWI                0.092169   0.045241   2.037 0.042149 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 1.179 on 497 degrees of freedom
## Multiple R-squared:  0.245,  Adjusted R-squared:  0.2329 
## F-statistic: 20.16 on 8 and 497 DF,  p-value: < 2.2e-16
```

Comparing the outputs of both the full and step-wise MLR models, there
is very little difference in the model diagnostics such as the
*R*<sup>2</sup>. Both models explain about 25% of variation of the
target variable. Obviously the ‘full’ model is more complex as it has
more parameters than the ‘step’ model. If we apply [Occam’s
Razor](http://math.ucr.edu/home/baez/physics/General/occam.html)
philosophy, the ‘step’ model is preferable.

<a href="#top">Back to top</a>

### Cross-validation <a id="s-6"></a>

As described earlier in the [cross-validation page](xxx), it is more
acceptable to test the performance of a model based upon an external
validation. Lets fit a new model using the covariates selected in the
step wise regression to a random subset of the available data. We will
sample 70% of the available rows for the model calibration data set.

```r
set.seed(123)
training <- sample(nrow(DSM_data), 0.7 * nrow(DSM_data))
hv.MLR.rh <- lm(pH60_100cm ~ AACN + Landsat_Band1 + Elevation + Hillshading + Mid_Slope_Positon + 
    MRVBF + NDVI + TWI, data = DSM_data[training, ])
# calibration predictions
hv.pred.rhC <- predict(hv.MLR.rh, DSM_data[training, ])

# validation predictions
hv.pred.rhV <- predict(hv.MLR.rh, DSM_data[-training, ])
```

Now we can evaluate the test statistics of the calibration model using
the `goof` function.

```r
# calibration
goof(observed = DSM_data$pH60_100cm[training], predicted = hv.pred.rhC)

##          R2 concordance      MSE     RMSE          bias
## 1 0.2380964   0.3835304 1.336101 1.155898 -7.105427e-15

# validation
goof(observed = DSM_data$pH60_100cm[-training], predicted = hv.pred.rhV)

##          R2 concordance      MSE     RMSE       bias
## 1 0.2393744   0.3791514 1.445582 1.202323 0.06681039
```

In this situation the calibration model does not appear to be over
fitting because the test statistics for the validation are similar to
those of the calibration data. While this is a good result, the
prediction model performs only moderately well by the fact there is a
noticeable deviation between observations and corresponding model
predictions. Examining other candidate models is a way to try to improve
upon these results.

<a href="#top">Back to top</a>

## Applying the model spatially <a id="s-7"></a>

There are a few ways to go about [applying a model spatially](xxx), but
here we will just use the `raster` `predict` function. In order to
eliminate any errors it is necessary to have all the predictive
covariates arranged as a `rasterStack` object. This is useful as it also
ensures all the rasters are of the same extent and resolution. Here we
can use the `raster` `predict` function such as below using the
`hunterCovariates_sub` raster stack loaded earlier as input.

```r
map.MLR.r1 <- predict(hunterCovariates_sub, hv.MLR.rh, "soilpH_60_100_MLR.tif", format = "GTiff", 
    datatype = "FLT4S", overwrite = TRUE)
# check working directory for presence of raster
```

The useful feature of the `predict` function in this context is that we
can write to file directly. This entails leveraging some of the
parameters used within the `writeRaster` function that are worth noting
and include: `format`, which is the raster format that we want to write
to. Here `GTiff` is being specified — use the `writeFormats` function to
look at what other raster formats can be used. The parameter `datatype`
is specified as `FLT4S` which indicates that a 4 byte, signed floating
point values are to be written to file. Look at the function `dataType`
to look at other alternatives, for example for categorical data where we
may be interested in logical or integer values.

<figure>
    <img src="{{ site.url }}/images/dsm_book/MLRcvt_hv.png" alt="rconsole">
    <figcaption> MLR predicted soil pH 60-100cm across the Hunter Valley.</figcaption>
</figure>


<a href="#top">Back to top</a>

### Other possible spatial predictions (prediction intervals) <a id="s-8"></a>

The prediction function is quite versatile. For example we can also map
the standard error of prediction or the confidence interval or the
prediction interval even. The script below is an example of creating
maps of the 90% prediction intervals for the model. We need to
explicitly create a function called in this case `predfun` which will
direct the raster `predict` function to output the predictions plus the
upper and lower prediction limits. In the `predict` function we insert
`predfun` for the `fun` parameter and control the output by changing the
`index` value to either 1, 2, or 3 to request either the prediction,
lower limit, upper limit respectively. Setting the `level` parameter to
0.90 indicates that we want to return the 90% prediction interval.

```r
# prediction interval function
predfun <- function(model, data) {
    v <- predict(model, data, interval = "prediction", level = 0.9)
}

par(mfrow = c(3, 1))  # plotting parameter

# perform the predictions
map.MLR.r.1ow <- predict(hunterCovariates_sub, hv.MLR.rh, "soilPh_60_100_MLR_low.tif", 
    fun = predfun, index = 2, format = "GTiff", datatype = "FLT4S", overwrite = TRUE)
plot(map.MLR.r.1ow, main = "MLR predicted soil pH (60-100cm) lower limit")

map.MLR.r.pred <- predict(hunterCovariates_sub, hv.MLR.rh, "soilPh_60_100_MLR_pred.tif", 
    fun = predfun, index = 1, format = "GTiff", datatype = "FLT4S", overwrite = TRUE)
plot(map.MLR.r.pred, main = "MLR predicted soil pH (60-100cm)")

map.MLR.r.up <- predict(hunterCovariates_sub, hv.MLR.rh, "soilPh_60_100_MLR_up.tif", 
    fun = predfun, index = 3, format = "GTiff", datatype = "FLT4S", overwrite = TRUE)
plot(map.MLR.r.up, main = "MLR predicted soil pH (60-100cm) upper limit")
# check working directory for presence of rasters
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/MLRrul_hv.png" alt="rconsole">
    <figcaption> MLR predicted soil pH (60-100cm) across the Hunter Valley with associated lower and upper prediction limits.</figcaption>
</figure>


<a href="#top">Back to top</a>