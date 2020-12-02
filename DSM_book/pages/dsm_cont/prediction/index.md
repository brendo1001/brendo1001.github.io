---
layout: page
title: Spatial Prediction
description: ""
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-07-26
---

## Applying models spatially

Here we will provide a brief overview of how applying models to unseen
data. The general idea is that one has fitted a model to predict some
soil phenomena using a suite of environmental covariates. Now you need
to use that model to apply to a the same covariates, but now these
covariates have continuous coverage across the area. Essentially you
want to create a soil map. There are a couple of ways to go about this.
First things first we need to prepare some data and fit a simple model.

-   [Data preparation](#s-1)
-   [Model fitting](#s-2)
-   [Apply model: Covariate data frame](#s-3)
-   [Apply model: raster `predict` function](#s-4)
-   [Apply model: Parallel processing](#s-5)

### Data preparation <a id="s-1"></a>

Recall from before in the data preparatory exercises that we were
working with the soil point data and environmental covariates for the
Hunter Valley area. These data are stored in the `HV_subsoilpH` and
`hunterCovariates_sub` objects from the `ithir` package.

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

Perform the covariate intersection.

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

<a href="#top">Back to top</a>

### Model fitting <a id="s-2"></a>

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

### Applying the model spatially using data frames <a id="s-3"></a>

The traditional approach has been to collate a grid table where there
would be two columns for the coordinates followed by other columns for
each of the available covariates that were sourced. This was seen as an
efficient way to organize all the covariate data as it ensured that a
common grid was used which also meant that all the covariates are of the
same scale in terms of resolution and extent. We can simulate the
covariate table approach using the `hunterCovariates_sub` object as
below.

```r
data(hunterCovariates_sub)
tempD <- data.frame(cellNos = seq(1:ncell(hunterCovariates_sub)))
vals <- as.data.frame(getValues(hunterCovariates_sub))
tempD <- cbind(tempD, vals)
tempD <- tempD[complete.cases(tempD), ]
cellNos <- c(tempD$cellNos)
gXY <- data.frame(xyFromCell(hunterCovariates_sub, cellNos, spatial = FALSE))
tempD <- cbind(gXY, tempD)
str(tempD)

## 'data.frame':    33252 obs. of  14 variables:
##  $ x                       : num  340935 340960 340985 341010 341035 ...
##  $ y                       : num  6370416 6370416 6370416 6370416 6370416 ...
##  $ cellNos                 : int  101 102 103 104 105 106 107 108 109 110 ...
##  $ Terrain_Ruggedness_Index: num  0.745 0.632 0.535 0.472 0.486 ...
##  $ AACN                    : num  9.78 9.86 10.04 10.27 10.53 ...
##  $ Landsat_Band1           : num  68 63 59 62 56 54 59 62 54 56 ...
##  $ Elevation               : num  103 103 102 102 102 ...
##  $ Hillshading             : num  0.94 0.572 0.491 0.515 0.568 ...
##  $ Light_insolation        : num  1712 1706 1701 1699 1697 ...
##  $ Mid_Slope_Positon       : num  0.389 0.387 0.386 0.386 0.386 ...
##  $ MRVBF                   : num  0.376 0.765 1.092 1.54 1.625 ...
##  $ NDVI                    : num  -0.178 -0.18 -0.164 -0.169 -0.172 ...
##  $ TWI                     : num  16.9 17.2 17.2 17.2 17.2 ...
##  $ Slope                   : num  0.968 0.588 0.503 0.527 0.581 ...
```

The result shown above is that the covariate table contains 33252 rows
and has 14 variables. It is always necessary to have the coordinate
columns, but some saving of memory could be earned if only the required
covariates are appended to the table. It will quickly become obvious
however that the covariate table approach could be limiting when mapping
extents get very large or the grid resolution of mapping becomes more
fine-grained, or both.

With the covariate table arranged it then becomes a matter of using the
MLR `predict` function.

```r
map.MLR <- predict(hv.MLR.Full, newdata = tempD)
map.MLR <- cbind(data.frame(tempD[, c("x", "y")]), map.MLR)
```

Now we can rasterise the predictions for mapping and grid export. In the
example below we set the CRS to WGS84 Zone 56 before exporting the
raster file out as a Geotiff file.

```r
map.MLR.r <- rasterFromXYZ(as.data.frame(map.MLR[, 1:3]))
plot(map.MLR.r, main = "MLR predicted soil pH (60-100cm)")
# set the projection
crs(map.MLR.r) <- "+proj=utm +zone=56 + south + ellps=WGS84 +datum=WGS84 +units=m +no_defs"
writeRaster(map.MLR.r, "soilpH_60_100_MLR.tif", format = "GTiff", datatype = "FLT4S", 
    overwrite = TRUE)
# check working directory for presence of raster
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/MLRcvt_hv.png" alt="rconsole">
    <figcaption> MLR predicted soil pH 60-100cm across the Hunter Valley.</figcaption>
</figure>

Some of the parameters used within the `writeRaster` function that are
worth noting include: `format`, which is the raster format that we want
to write to. Here `GTiff` is being specified — use the `writeFormats`
function to look at what other raster formats can be used. the parameter
`datatype` is specified as `FLT4S` which indicates that a 4 byte, signed
floating point values are to be written to file. Look at the function
`dataType` to look at other alternatives, for example for categorical
data where we may be interested in logical or integer values.

### Applying the model spatially using `raster predict` <a id="s-4"></a>

Probably a more efficient way of applying the fitted model is to apply
it directly to the rasters themselves. This avoids the step of arranging
all covariates into table format. If multiple rasters are being used, it
is necessary to have them arranged as a `rasterStack` object. This is
useful as it also ensures all the rasters are of the same extent and
resolution. Here we can use the `raster` `predict` function such as
below using the `covStack` raster stack as input.

```r
map.MLR.r1 <- predict(hunterCovariates_sub, hv.MLR.Full, "soilpH_60_100_MLR.tif", 
    format = "GTiff", datatype = "FLT4S", overwrite = TRUE)
# check working directory for presence of raster
```

<a href="#top">Back to top</a>

### Applying the model spatially using parallel processing <a id="s-5"></a>

An extension of using the raster `predict` function is to apply the
model again to the rasters, but to do it across multiple computer nodes.
This is akin to breaking a job up into smaller pieces then processing
the jobs in parallel rather than sequentially. The parallel component
here is that the smaller pieces are passed to more than 1 compute nodes.
Most desktop computers these days can have up to 8 compute nodes which
can result in some excellent gains in efficiency when applying models
across massive extents and or at fine resolutions. The `raster` package
has some built in dependencies with other `R` packages that facilitate
parallel processing options. For example the `raster` package ports with
the `parallel` package for setting up and controlling the compute node
processes. The script below is an example of using 4 compute nodes to
apply the `hv.MLR.Full` model to the `hunterCovariates_sub` raster
stack.

```r
library(parallel)
beginCluster(4)
cluserMLR.pred <- clusterR(hunterCovariates_sub, predict, args = list(hv.MLR.Full), 
    filename = "soilpH_60_100_MLR_pred.tif", format = "GTiff", progress = FALSE, 
    overwrite = T)
endCluster()
```

To set up the compute nodes, you use the `beginCluster` function and
inside it, specify how many compute nodes you want to use. If empty
brackets are used, the function will use 100% of the compute resources.
The `clusterR` function is the work horse function that then applies the
model in parallel to the rasters. The parameters and subsequent options
are similar to the raster `predict` function, although it would help to
look at the help files on this function for more detailed explanations.
It is always important after the prediction is completed to shutdown the
nodes using the `endCluster` function.

The relative ease in setting up the parallel processing for our mapping
needs has really opened up the potential for performing DSM using very
large data sets and rasters. Moreover, using the parallel processing
together with the file pointing ability (that was discussed earlier)
`raster` has made the possibility of big DSM a reality, and importantly-
practicable.

<a href="#top">Back to top</a>
