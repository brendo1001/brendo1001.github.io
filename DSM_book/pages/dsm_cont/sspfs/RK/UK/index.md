---
layout: page
title: Universal Kriging
description: "Continuous Variables"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-08-29
---

-   [Introduction](#s-1)
-   [Data preparation](#s-2)
-   [Perform the covariate intersection](#s-3)
-   [Model fitting](#s-4)
-   [External validation](#s-5)
-   [Interpolation](#s-6)

### Introduction <a id="s-1"></a>

The universal kriging function in `R` is found in the `gstat` package.
It is useful from the view that both the regression model and variogram
modeling of the residuals are handled together. Using universal kriging,
one can efficiently derive prediction uncertainties by way of the
kriging variance. A limitation of universal kriging in the true sense of
the model parameter fitting is that the model is linear. The general
preference is DSM studies is to used non-linear and recursive models
that do not require strict model assumptions and assume a linear
relationship between target variable and covariates.

<a href="#top">Back to top</a>

### Data preparation <a id="s-2"></a>

So lets firstly get the data organized. Recall from before in the [data preparatory exercises]({{ site.url}}/DSM_book/pages/dsm_prep/processes/)
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

#### Perform the covariate intersection <a id="s-3"></a>

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

#### Model fitting <a id="s-4"></a>

One of the strict requirements of universal kriging in `gstat` is that
the CRS (coordinate reference system) of the point data and covariates
must be exactly the same. First we will take a subset of the data to use
for an external validation.

```r
set.seed(123)
training <- sample(nrow(DSM_data), 0.7 * nrow(DSM_data))
cDat <- DSM_data[training, ]

coordinates(cDat) <- ~x + y
# assigin CRS to point data
crs(cDat) <- "+proj=utm +zone=56 +south +ellps=WGS84 + datum=WGS84 +units=m +no_defs"
# give the covariate data the same crs
crs(hunterCovariates_sub) = crs(cDat)

# check
crs(cDat)

## CRS arguments:
##  +proj=utm +zone=56 +south +ellps=WGS84 +units=m +no_defs

crs(hunterCovariates_sub)

## CRS arguments:
##  +proj=utm +zone=56 +south +ellps=WGS84 +units=m +no_defs
```

Now lets parametise the universal kriging model, and we will use
selected covariates that were used in the [multiple linear regression example]({{ site.url }}/DSM_book/pages/dsm_cont/sspfs/mlr/).

```r
library(gstat)
vgm1 <- variogram(pH60_100cm ~ AACN + Landsat_Band1 + Elevation + Hillshading + Mid_Slope_Positon + 
    MRVBF + NDVI + TWI, cDat, width = 200, cutoff = 3000)
mod <- vgm(psill = var(cDat$pH60_100cm), "Exp", range = 3000, nugget = 0)
model_1 <- fit.variogram(vgm1, mod)
model_1

##   model     psill    range
## 1   Nug 0.5386983   0.0000
## 2   Exp 0.8326639 221.5831

# Universal kriging model
gUK <- gstat(NULL, "pH", pH60_100cm ~ AACN + Landsat_Band1 + Elevation + Hillshading + 
    Mid_Slope_Positon + MRVBF + NDVI + TWI, cDat, model = model_1)
```

<a href="#top">Back to top</a>

#### External validation <a id="s-5"></a>

Using the validation data we can assess the performance of universal
kriging using the `goof` function.

```r
vDat <- DSM_data[-training, ]
coordinates(vDat) <- ~x + y
crs(vDat) <- "+proj=utm +zone=56 +south +ellps=WGS84 + datum=WGS84 +units=m +no_defs"

crs(vDat)

## CRS arguments:
##  +proj=utm +zone=56 +south +ellps=WGS84 +units=m +no_defs

# make the predictions
UK.preds.V <- as.data.frame(krige(pH60_100cm ~ AACN + Landsat_Band1 + Elevation + 
    Hillshading + Mid_Slope_Positon + MRVBF + NDVI + TWI, cDat, model = model_1, 
    newdata = vDat))

## [using universal kriging]

goof(observed = DSM_data$pH60_100cm[-training], predicted = UK.preds.V[, 3])

##          R2 concordance   MSE     RMSE      bias
## 1 0.4333118   0.5779432 1.077 1.037786 0.0287364
```

The universal kriging model performs a little better than the
[MLR]({{ site.url }}/DSM_book/pages/dsm_cont/sspfs/mlr/)
that was fitted earlier.

<a href="#top">Back to top</a>

#### Interpolation <a id="s-6"></a>

Applying the universal kriging model spatially is facilitated through
the `interpolate` function from `raster`. One can also use the
`clusterR` function used [earlier]({{ site.url }}/DSM_book/pages/dsm_cont/prediction/)
in order to speed things up a bit by applying the model over multiple
compute nodes.

Kriging results in two main outputs: the prediction and the prediction
variance. When using the `interpolate` function we can control the
output by changing the `index` parameter.

```r
par(mfrow = c(1, 2))
# predictions
UK.P.map <- interpolate(hunterCovariates_sub, gUK, xyOnly = FALSE, index = 1)
plot(UK.P.map, main = "Universal kriging predictions")

# prediction variance
UK.Pvar.map <- interpolate(hunterCovariates_sub, gUK, xyOnly = FALSE, index = 2)
plot(UK.Pvar.map, main = "Universal kriging prediction variance")
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/UKmap_hv.png" alt="rconsole">
    <figcaption> Universal kriging prediction and prediction variance of Hunter Valley soil pH (60-100cm).</figcaption>
</figure>

<a href="#top">Back to top</a>