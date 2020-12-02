---
layout: page
title: "Quantification of prediction uncertainties"
description:  "Universal kriging prediction variance"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-11-24
---

## Introduction

-   [Defining the model parameters](#s-1)
-   [Spatial Mapping](#s-2)
-   [Validating the quantification of uncertainties](#s-3)

In the page regarding digital soil mapping of continuous variables,
[universal kriging was explored]({{ site.url }}/DSM_book/pages/dsm_cont/sspfs/RK/UK/). This model is ideal from the perspective that both the correlated
variables and model residuals are handled simultaneously. This model
also automatically generates prediction uncertainty via the kriging
variance. It is with this variance estimate that we can define a
prediction interval. Here, a 90% prediction interval will be defined for
the mapping purposes. Although for validation, a number of levels of
confidence will be defined and subsequently validated in order to assess
the performance and sensitivity of the uncertainty estimates.

### Defining the model parameters <a id="s-1"></a>

First we need to load in all the libraries that are necessary for this
section and load in the necessary data.

```r
library(ithir)
library(sp)
library(rgdal)

## rgdal: version: 1.4-4, (SVN revision 833)
##  Geospatial Data Abstraction Library extensions to R successfully loaded
##  Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
##  Path to GDAL shared files: /usr/share/gdal/2.2
##  GDAL binary built with GEOS: TRUE 
##  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
##  Path to PROJ.4 shared files: (autodetected)
##  Linking to sp version: 1.3-1

library(raster)
library(gstat)

## Registered S3 method overwritten by 'xts':
##   method     from
##   as.zoo.xts zoo

# Point data
data(HV_subsoilpH)
str(HV_subsoilpH)

## 'data.frame':    506 obs. of  14 variables:
##  $ X                       : num  340386 340345 340559 340483 340734 ...
##  $ Y                       : num  6368690 6368491 6369168 6368740 6368964 ...
##  $ pH60_100cm              : num  4.47 5.42 6.26 8.03 8.86 ...
##  $ Terrain_Ruggedness_Index: num  1.34 1.42 1.64 1.04 1.27 ...
##  $ AACN                    : num  1.619 0.281 2.301 1.74 3.114 ...
##  $ Landsat_Band1           : int  57 47 59 52 62 53 47 52 53 63 ...
##  $ Elevation               : num  103.1 103.7 99.9 101.9 99.8 ...
##  $ Hillshading             : num  1.849 1.428 0.934 1.517 1.652 ...
##  $ Light_insolation        : num  1689 1701 1722 1688 1735 ...
##  $ Mid_Slope_Positon       : num  0.876 0.914 0.844 0.848 0.833 ...
##  $ MRVBF                   : num  3.85 3.31 3.66 3.92 3.89 ...
##  $ NDVI                    : num  -0.143 -0.386 -0.197 -0.14 -0.15 ...
##  $ TWI                     : num  17.5 18.2 18.8 18 17.8 ...
##  $ Slope                   : num  1.79 1.42 1.01 1.49 1.83 ...

# Raster data
data(hunterCovariates_sub)
hunterCovariates_sub

## class      : RasterStack 
## dimensions : 249, 210, 52290, 11  (nrow, ncol, ncell, nlayers)
## resolution : 25, 25  (x, y)
## extent     : 338422.3, 343672.3, 6364203, 6370428  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=56 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs 
## names      : Terrain_Ruggedness_Index,        AACN, Landsat_Band1,   Elevation, Hillshading, Light_insolation, Mid_Slope_Positon,       MRVBF,        NDVI,         TWI,       Slope 
## min values :                 0.194371,    0.000000,     26.000000,   72.217499,    0.000677,      1236.662840,          0.000009,    0.000002,   -0.573034,    8.224325,    0.001708 
## max values :                15.945321,  106.665482,    140.000000,  212.632507,   32.440960,      1934.199950,          0.956529,    4.581594,    0.466667,   20.393652,   21.809752
```

You will notice for `HV_subsoilpH` that these data have already been
intersected with a number of covariates. The `hunterCovariates_sub` are
a `rasterStack` of the same covariates (although the spatial extent is
smaller).

Now to prepare the data for the universal kriging model. Below we
partition the dataset via a randomized sub-setting whereby 70% of the
data is used for model fitting work, leaving the other 30% for
independent validation of the model plus the quantification of
uncertainties.

```r
# subset data for modeling
set.seed(123)
training <- sample(nrow(HV_subsoilpH), 0.7 * nrow(HV_subsoilpH))
cDat <- HV_subsoilpH[training, ]
vDat <- HV_subsoilpH[-training, ]
nrow(cDat)

## [1] 354

nrow(vDat)

## [1] 152
```

The `cDat` and `vDat` objects correspond to the model calibration and
validation data sets respectively.

Now to prepare the data for the model. here we are specifying the
spatial coordinate structure of the data.

```r
# coordinates
coordinates(cDat) <- ~X + Y

# remove CRS from grids
crs(hunterCovariates_sub) <- NULL
```

We will firstly use a step wise regression to determine a parsimonious
model are the most important covariates.

```r
# Full model
lm1 <- lm(pH60_100cm ~ Terrain_Ruggedness_Index + AACN + Landsat_Band1 + Elevation + 
    Hillshading + Light_insolation + Mid_Slope_Positon + MRVBF + NDVI + TWI + 
    Slope, data = cDat)

# Parsimous model
lm2 <- step(lm1, direction = "both", trace = 0)
as.formula(lm2)

## pH60_100cm ~ AACN + Landsat_Band1 + Elevation + Hillshading + 
##     Mid_Slope_Positon + MRVBF + NDVI + TWI

summary(lm2)

## 
## Call:
## lm(formula = pH60_100cm ~ AACN + Landsat_Band1 + Elevation + 
##     Hillshading + Mid_Slope_Positon + MRVBF + NDVI + TWI, data = cDat)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -3.0255 -0.7677 -0.1066  0.7161  3.4354 
## 
## Coefficients:
##                    Estimate Std. Error t value Pr(>|t|)    
## (Intercept)        7.699430   1.065126   7.229 3.16e-12 ***
## AACN               0.041764   0.008303   5.030 7.89e-07 ***
## Landsat_Band1     -0.038015   0.010637  -3.574 0.000402 ***
## Elevation         -0.017069   0.006305  -2.707 0.007119 ** 
## Hillshading        0.100432   0.021836   4.599 5.96e-06 ***
## Mid_Slope_Positon  0.997455   0.314699   3.170 0.001663 ** 
## MRVBF              0.258095   0.101318   2.547 0.011287 *  
## NDVI               4.964339   1.028226   4.828 2.08e-06 ***
## TWI                0.113413   0.053713   2.111 0.035453 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 1.169 on 345 degrees of freedom
## Multiple R-squared:  0.2403, Adjusted R-squared:  0.2227 
## F-statistic: 13.64 on 8 and 345 DF,  p-value: < 2.2e-16
```

Now we can construct the universal kriging model using the step wise
selected covariates.

```r
vgm1 <- variogram(pH60_100cm ~ AACN + Landsat_Band1 + Hillshading + Mid_Slope_Positon + 
    MRVBF + NDVI + TWI, cDat, width = 200)
mod <- vgm(psill = var(cDat$pH60_100cm), "Sph", range = 10000, nugget = 0)
model_1 <- fit.variogram(vgm1, mod)

gUK <- gstat(NULL, "hunterpH_UK", pH60_100cm ~ AACN + Landsat_Band1 + Hillshading + 
    Mid_Slope_Positon + MRVBF + NDVI + TWI, cDat, model = model_1)
gUK

## data:
## hunterpH_UK : formula = pH60_100cm`~`AACN + Landsat_Band1 + Hillshading + Mid_Slope_Positon + MRVBF + NDVI + TWI ; data dim = 354 x 12
## variograms:
##                model     psill    range
## hunterpH_UK[1]   Nug 0.7118707   0.0000
## hunterpH_UK[2]   Sph 0.6574215 652.7561
```

<a href="#top">Back to top</a>

### Spatial mapping <a id="s-2"></a>

Here we want to produce four maps that will correspond to:

1.  The lower end of the 90% prediction interval or 5<sup>*t**h*</sup>
    percentile of the empirical probability density function.
2.  The universal kriging prediction.
3.  The upper end of the 90% prediction interval or 95<sup>*t**h*</sup>
    percentile of the empirical probability density function.
4.  The prediction interval range.

For the prediction we use the raster `interpolate` function.

```r
UK.P.map <- interpolate(hunterCovariates_sub, gUK, xyOnly = FALSE, index = 1, 
    filename = "UK_predMap.tif", format = "GTiff", overwrite = T)
```

Setting the `index` value to 2 lets us map the kriging variance which is
needed for the prediction interval. Taking the square root of this
estimates the standard deviation which we can then multiply by the
quantile function value that corresponds either the lower
(5<sup>*t**h*</sup>) or upper tail ((95<sup>*t**h*</sup>)) probability
which is 1.644854. We then both add and subtract this value from the
universal kriging prediction to derive the 90% prediction limits.

```r
# prediction variance
UK.var.map <- interpolate(hunterCovariates_sub, gUK, xyOnly = FALSE, index = 2, filename="UK_predVarMap.tif",format="GTiff",overwrite=T)

#standard deviation
f2 <- function(x) (sqrt(x)) 
UK.stdev.map <- calc(UK.var.map, fun=f2,filename="UK_predSDMap.tif",format="GTiff",progress="text",overwrite=T)

#Z level
zlev<- qnorm(0.95)
f2 <- function(x) (x * zlev) 
UK.mult.map <- calc(UK.stdev.map, fun=f2,filename="UK_multMap.tif",format="GTiff",progress="text",overwrite=T)

#Add and subtract mult from prediction
m1<- stack(UK.P.map,UK.mult.map)

#upper PL
f3 <- function(x) (x[1] + x[2]) 
UK.upper.map <- calc(m1, fun=f3,filename="UK_upperMap.tif",format="GTiff",progress="text",overwrite=T)

#lower PL
f4 <- function(x) (x[1] - x[2]) 
UK.lower.map <- calc(m1, fun=f4,filename="UK_lowerMap.tif",format="GTiff",progress="text",overwrite=T)
@

\indent Finally to derive the 90\% prediction limit range

<<echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE,warning = FALSE, message = FALSE, background='white'>>=
# prediction range
m2<- stack(UK.upper.map,UK.lower.map)

f5 <- function(x) (x[1] - x[2]) 
UK.piRange.map <- calc(m2, fun=f5,filename="UK_piRangeMap.tif",format="GTiff",progress="text",overwrite=T)
```

Finally to derive the 90% prediction limit range.

```r
# prediction range
m2 <- stack(UK.upper.map, UK.lower.map)

f5 <- function(x) (x[1] - x[2])
UK.piRange.map <- calc(m2, fun = f5, filename = "UK_piRangeMap.tif", format = "GTiff", 
    progress = "text", overwrite = T)
```

So to plot them all together we use the following script. Here we
explicitly create a color ramp that follows reasonably closely the pH
color ramp. Then we scale each map to the common range for better
comparison.

```r
# color ramp
phCramp <- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598", 
    "#abdda4", "#66c2a5", "#3288bd", "#5e4fa2", "#542788", "#2d004b")
brk <- c(2:14)
par(mfrow = c(2, 2))
plot(UK.lower.map, main = "90% Lower prediction limit", breaks = brk, col = phCramp)
plot(UK.P.map, main = "Prediction", breaks = brk, col = phCramp)
plot(UK.upper.map, main = "90% Upper prediction limit", breaks = brk, col = phCramp)
plot(UK.piRange.map, main = "Prediction limit range", col = terrain.colors(length(seq(0, 
    6.5, by = 1)) - 1), axes = FALSE, breaks = seq(0, 6.5, by = 1))
```
<figure>
    <img src="{{ site.url }}/images/dsm_book/uncert_UKmaps.png" alt="rconsole">
    <figcaption> Soil pH predictions and prediction limits derived using a universal kriging model.</figcaption>
</figure>


<a href="#top">Back to top</a>

### Validating the quantification of uncertainty <a id="s-3"></a>

One of the ways to assess the performance of the uncertainty
quantification is to evaluate the occurrence of times where an observed
value is encapsulated by an associated prediction interval. Given a
stated level of confidence, we should also expect to find the same
percentage of observations encapsulated by its associated prediction
interval. We define this percentage as the prediction interval coverage
probability (PICP). The PICP was used in both Solomatine and Shrestha
(2009) and Malone, McBratney, and Minasny (2011). To assess the
sensitivity of the uncertainty quantification, we define prediction
intervals at a number of levels of confidence and then assess the PICP.
Ideally, a 1:1 relationship would ensue.

First we apply the universal kriging model `gUK` to the validation data
in order to estimate pH and the prediction variance.

```r
coordinates(vDat) <- ~X + Y

# Prediction
UK.preds.V <- as.data.frame(krige(pH60_100cm ~ AACN + Landsat_Band1 + Hillshading + 
    Mid_Slope_Positon + MRVBF + NDVI + TWI, cDat, model = model_1, newdata = vDat))

## [using universal kriging]

UK.preds.V$stdev <- sqrt(UK.preds.V$var1.var)
str(UK.preds.V)

## 'data.frame':    152 obs. of  5 variables:
##  $ X        : num  340386 340559 340780 340861 340905 ...
##  $ Y        : num  6368690 6369168 6369166 6368874 6368790 ...
##  $ var1.pred: num  7.4 7.1 7.35 6.53 5.71 ...
##  $ var1.var : num  1.04 1.21 1.2 1.17 1.19 ...
##  $ stdev    : num  1.02 1.1 1.09 1.08 1.09 ...
```

Then we define a vector of quantile function values for a sequence of
probabilities using the `qnorm` function.

```r
qp <- qnorm(c(0.995, 0.9875, 0.975, 0.95, 0.9, 0.8, 0.7, 0.6, 0.55, 0.525))
```

Then we estimate the prediction limits for each confidence level.

```r
# zfactor multiplication
vMat <- matrix(NA, nrow = nrow(UK.preds.V), ncol = length(qp))
for (i in 1:length(qp)) {
    vMat[, i] <- UK.preds.V$stdev * qp[i]
}

# upper
uMat <- matrix(NA, nrow = nrow(UK.preds.V), ncol = length(qp))
for (i in 1:length(qp)) {
    uMat[, i] <- UK.preds.V$var1.pred + vMat[, i]
}

# lower
lMat <- matrix(NA, nrow = nrow(UK.preds.V), ncol = length(qp))
for (i in 1:length(qp)) {
    lMat[, i] <- UK.preds.V$var1.pred - vMat[, i]
}
```

Then we want to evaluate the PICP for each confidence level.

```r
bMat <- matrix(NA, nrow = nrow(UK.preds.V), ncol = length(qp))
for (i in 1:ncol(bMat)) {
    bMat[, i] <- as.numeric(vDat$pH60_100cm <= uMat[, i] & vDat$pH60_100cm >= 
        lMat[, i])
}

colSums(bMat)/nrow(bMat)

##  [1] 0.97368421 0.96052632 0.94078947 0.90789474 0.82236842 0.63815789
##  [7] 0.45394737 0.22368421 0.10526316 0.05921053
```

Plotting the confidence level against the PICP provides a visual means
to assess the fidelity about the 1:1 line. As can be seen below, the
PICP follows closely the 1:1 line.

```r
# make plot
cs <- c(99, 97.5, 95, 90, 80, 60, 40, 20, 10, 5)
plot(cs, ((colSums(bMat)/nrow(bMat)) * 100))
```
<figure>
    <img src="{{ site.url }}/images/dsm_book/PICP_UK.png" alt="rconsole">
    <figcaption> Plot of PICP and confidence level based on validation of universal kriging model.</figcaption>
</figure>


So to summarize. We may evaluate the performance of the universal
kriging model on the basis of the predictions. Using the validation data
we would use the `goof` function for that purpose.

```r
ithir::goof(observed = vDat$pH60_100cm, predicted = UK.preds.V$var1.pred)

##          R2 concordance      MSE     RMSE       bias
## 1 0.4299833    0.571746 1.083256 1.040796 0.04779541
```

And then we may assess the uncertainties on the basis of the PICP like
shown below, together with assessing the quantiles of the distribution
of the prediction limit range for a given prediction confidence level
(here 90%).

```r
cs <- c(99, 97.5, 95, 90, 80, 60, 40, 20, 10, 5)  # confidence level
colnames(lMat) <- cs
colnames(uMat) <- cs
quantile(uMat[, "90"] - lMat[, "90"])

##       0%      25%      50%      75%     100% 
## 2.983870 3.274481 3.400427 3.500311 3.889930
```

As can be noted above, the prediction interval range is relatively
homogeneous and this is corroborated on the associated map created
earlier.

<a href="#top">Back to top</a>

### References

<a href="#top">Back to top</a>

Malone, B P, A B McBratney, and B Minasny. 2011. “Empirical Estimates of
Uncertainty for Mapping Continuous Depth Functions of Soil Attributes.”
*Geoderma* 160: 614–26.

Solomatine, D. P, and D. L Shrestha. 2009. “A Novel Method to Estimate
Model Uncertainty Using Machine Learning Techniques.” *Water Resources
Research* 45: Article Number: W00B11.
