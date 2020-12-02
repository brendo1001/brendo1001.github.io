---
layout: page
title: Hybrid regression kriging
description: "Continuous Variables"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-08-30
---

-   [Introduction](#s-1)
-   [Data preparation](#s-2)
-   [Perform the covariate intersection](#s-3)
-   [Model fitting](#s-4)
-   [External validation](#s-5)
-   [Spatial prediction](#s-6)

### Introduction <a id="s-1"></a>

The following example will provide the steps one would use to perform
regression kriging that incorporates a complex model structure such as a
data mining algorithm. Here we will use the Cubist model that was used
earlier. Lets start from the beginning.

<a href="#top">Back to top</a>

### Data preparation <a id="s-2"></a>

So lets firstly get the data organized. Recall from before in the [data preparatory exercises]({{site.url}}/DSM_book/pages/dsm_prep/processes/)
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

### Model Fitting <a id="s-4"></a>

For the structural part of the regression kriging model lets first
perform the cubist model fitting.

```r
library(Cubist)

## Loading required package: lattice

# create a calibration data set via random selection of a subset
set.seed(875)
training <- sample(nrow(DSM_data), 0.7 * nrow(DSM_data))
mDat <- DSM_data[training, ]

# fit the model
hv.cub.Exp <- cubist(x = mDat[, c("AACN", "Landsat_Band1", "Elevation", "Hillshading", 
    "Mid_Slope_Positon", "MRVBF", "NDVI", "TWI")], y = mDat$pH60_100cm, cubistControl(rules = 100, 
    extrapolation = 15), committees = 1)

Now derive the model residual which is the model prediction subtracted
from the residual.

mDat$residual <- mDat$pH60_100cm - predict(hv.cub.Exp, newdata = mDat)
mean(mDat$residual)

## [1] 0.1086524
```

If you check the histogram of these residuals you will find that the
mean is around zero and the data seems normally distributed. Now we can
assess the residuals for any spatial structure using a variogram model.

```r
library(gstat)
coordinates(mDat) <- ~x + y
crs(mDat) <- "+proj=utm +zone=56 +south +ellps=WGS84 
             + datum=WGS84 +units=m +no_defs"

# Fit a spherical variogram
vgm1 <- variogram(residual ~ 1, mDat, width = 200, cutoff = 3000)
mod <- vgm(psill = var(mDat$residual), "Sph", range = 3000, nugget = 0)
model_1 <- fit.variogram(vgm1, mod)
model_1

##   model     psill    range
## 1   Nug 0.8030644    0.000
## 2   Sph 0.5676551 1111.159

# Residual kriging model
gRK <- gstat(NULL, "RKresidual", residual ~ 1, mDat, model = model_1)
```

<a href="#top">Back to top</a>

### External validation <a id="s-5"></a>

With the two model components together, we can now compare the external
validation statistics of using the Cubist model only and with the Cubist
model and residual variogram together.

```r
# Cubist model only predictions
Cubist.pred.V <- predict(hv.cub.Exp, newdata = DSM_data[-training, ])

# Cubist model with residual variogram
vDat <- DSM_data[-training, ]
coordinates(vDat) <- ~x + y
crs(vDat) <- "+proj=utm +zone=56 +south +ellps=WGS84 
            + datum=WGS84 +units=m +no_defs"

# make the residual predictions
RK.preds.V <- as.data.frame(krige(residual ~ 1, mDat, model = model_1, newdata = vDat))

## [using ordinary kriging]

# Sum the two components together
RK.preds.fin <- Cubist.pred.V + RK.preds.V[, 3]

# validation cubist only
goof(observed = DSM_data$pH60_100cm[-training], predicted = Cubist.pred.V)

##          R2 concordance      MSE     RMSE        bias
## 1 0.1963508     0.33224 1.506298 1.227313 -0.05218972

# validation regression kriging with cubist model
goof(observed = DSM_data$pH60_100cm[-training], predicted = RK.preds.fin)

##         R2 concordance      MSE     RMSE       bias
## 1 0.328646   0.5236584 1.258334 1.121755 0.09227384
```

These results confirm that there to be some advantage in performing
regression kriging with this particular data.

<a href="#top">Back to top</a>

### Spatial prediction <a id="s-6"></a>

To apply the regression kriging model spatially, there are 3 basic
steps. First apply the Cubist model, then apply the residual kriging,
then finally add both maps together. The script below illustrates how
this is done.

```r
par(mfrow = c(3, 1))
# Cubist model
map.RK1 <- predict(hunterCovariates_sub, hv.cub.Exp, filename = "soilpH_60_100_cubistRK.tif", 
    format = "GTiff", datatype = "FLT4S", overwrite = TRUE)
plot(map.RK1, main = "Cubist model predicted soil pH")

# kriging of cubist model residuals
map.RK2 <- interpolate(hunterCovariates_sub, gRK, xyOnly = TRUE, index = 1, filename = "soilpH_60_100_residualRK.tif", 
    format = "GTiff", datatype = "FLT4S", overwrite = TRUE)
plot(map.RK2, main = "Kriged residual")

# Stack prediction and kriged residuals
pred.stack <- stack(map.RK1, map.RK2)

map.RK3 <- calc(pred.stack, fun = sum, filename = "soilpH_60_100_finalPredRK.tif", 
    format = "GTiff", progress = "text", overwrite = T)
plot(map.RK3, main = "Regression kriging prediction")
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/RKmap_hvC.png" alt="rconsole">
    <figcaption> egression kriging predictions with cubist models. Hunter Valley soil pH (60-100cm).</figcaption>
</figure>


<a href="#top">Back to top</a>