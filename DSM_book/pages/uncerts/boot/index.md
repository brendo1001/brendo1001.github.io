---
layout: page
title: "Quantification of prediction uncertainties"
description:  "Bootstrapping."
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-11-24
---

-   [Introduction](#s-1)
-   [Defining the model parameters](#s-2)
-   [Spatial mapping ](#s-3)
-   [Validating the quantification of uncertainty](#s-4)
-   [References](#s-5)

### Introduction <a id="s-1"></a>

Bootstrapping is a non-parametric approach for quantifying prediction
uncertainties (Efron and Tibshirani 1993). Bootstrapping involves
repeated random sampling with replacement of the available data. With
the bootstrap sample, a model is fitted, and can then be applied to
generate a digital soil map. By repeating the process of random sampling
and applying the model, we are able to generate probability
distributions of the prediction realizations from each model at each
pixel. A robust estimate may be determined by taking the average of all
the simulated predictions at each pixel. By being able to obtain
probability distributions of the outcomes, one is also able to quantify
the uncertainty of the modeling by computing a prediction interval given
a specified level of confidence. While the bootstrapping approach is
relatively straightforward, there is a requirement to generate *x*
number of maps, where *x* is the number of bootstrap samples. This
obviously could be prohibitive from a computational and data storage
point of view, but not altogether impossible (given parallel processing
capabilities etc.) as was demonstrated by both Viscarra Rossel et al.
(2015) and Liddicoat et al. (2015) whom both performed bootstrapping for
quantification of uncertainties across very large mapping extents. In
the case of Viscarra Rossel et al. (2015) this for for the entire
Australian continent at 100m resolution.

In the example below, the bootstrap method is demonstrated. We will be
using Cubist modeling for the model structure and perform 50 bootstrap
samples. We will do the bootstrap model using 70% of the available data.
The remaining 30% will be used for an external validation and therefore
independent of any model calibration function (although that a
completely independent design-based sample).

<a href="#top">Back to top</a>

### Defining the model parameters <a id="s-2"></a>

For the first step, we do the random partitioning of the data into
calibration and validation data sets. Again we are using the
`HV_subsoilpH` data from the `ithir` package and the associated
`hunterCovariates_sub` raster data stack.

```r
library(ithir)
library(raster)
library(rgdal)
## DATA Point data
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

# subset data for modeling
set.seed(667)
training <- sample(nrow(HV_subsoilpH), 0.7 * nrow(HV_subsoilpH))
cDat <- HV_subsoilpH[training, ]
vDat <- HV_subsoilpH[-training, ]
```


The `nbag` variable below holds the value for the number of bootstrap
models we want to fit. Here it is 50. Essentially the bootstrap can can
be contained within a `for` loop, where upon each loop a sample of the
available data is taken of *n* size where the *n* is the same number of
cases in the model frame. This sampling is done with replacment however,
which works out to be about 66% of the model frame in terms of unique
cases. The other 34% of the data are used to assess the model goodness
of fit for each bootstrap iteration in terms of out-of-bag assessment,
which just means data not included in the model. Note below the use of
the `replace` parameter to indicate we want random sample with
replacement. After a model is fitted, we save the model to file and will
come back to it later. The `modelFile` variable shows the extensive use
of the `paste0` function in order to provide the pathway and file name
for the model that we want to save on each loop iteration. The `saveRDS`
function allows us to save each of the model objects as rds files to the
location specified. An alternative to save the models individually to
file is to save them to elements within a `list`. When dealing with very
large numbers of models and additionally are complex in terms of their
parameterizations, the save to `list` elements alternative could run
into computer memory limitation issues. The last section of the script
below just demonstrates the use of the `list.files` functions to confirm
that we have saved those models to file and they are ready to use.

```r
# Number of bootstraps
nbag <- 50

# Fit cubist models for each bootstrap
library(Cubist)
for (i in 1:nbag) {
    # sample with replacement
    trainingREP <- sample.int(nrow(cDat), replace = TRUE)
    
    # unique cases
    trainingREP <- unique(trainingREP)
    
    fit_cubist <- cubist(x = cDat[trainingREP, c("Terrain_Ruggedness_Index", "AACN", "Landsat_Band1", 
        "Elevation", "Hillshading", "Light_insolation", "Mid_Slope_Positon", "MRVBF", "NDVI", "TWI", 
        "Slope")], y = cDat$pH60_100cm[trainingREP], cubistControl(rules = 5, extrapolation = 5), committees = 1)
    
    ### Note you will likely have different file path names ###
    modelFile <- paste0(root, "models/bootMod_", i, ".rds")
    
    saveRDS(object = fit_cubist, file = modelFile)
}

# list all files in directory Note you will likely have different file path names ###
c.models <- list.files(path = paste0(root, "models/"), pattern = "\\.rds$", full.names = TRUE)
head(c.models)

## [1] "~/uncertaintyanalysis/bootstrap/models//bootMod_1.rds" 
## [2] "~/uncertaintyanalysis/bootstrap/models//bootMod_10.rds"
## [3] "~/uncertaintyanalysis/bootstrap/models//bootMod_11.rds"
## [4] "~/uncertaintyanalysis/bootstrap/models//bootMod_12.rds"
## [5] "~/uncertaintyanalysis/bootstrap/models//bootMod_13.rds"
## [6] "~/uncertaintyanalysis/bootstrap/models//bootMod_14.rds"
```


We can then assess the goodness of fit and validation statistics of the
bootstrap models. This is done using the `goof` function as in previous
examples. This time we incorporate that function within a `for` loop.
For each loop, we read in the model via the `radRDS` function and then
save the diagnostics to the `cubiMat` matrix object. After the
iterations are completed, we use the `colMeans` function to calculate
the means of the diagnostics over the 50 model iterations. You could
also assess the variance of those means by a command such as
`var(cubiDat[,1])`, which would return the variance of the
*R*<sup>2</sup> values.

```r
# calibration data
cubiMat <- matrix(NA, nrow = nbag, ncol = 5)
for (i in 1:nbag) {
    fit_cubist <- readRDS(c.models[i])
    cubiMat[i, ] <- as.matrix(goof(observed = cDat$pH60_100cm, predicted = predict(fit_cubist, newdata = cDat)))
}
cubiDat <- as.data.frame(cubiMat)
names(cubiDat) <- c("R2", "concordance", "MSE", "RMSE", "bias")
colMeans(cubiDat)

##          R2 concordance         MSE        RMSE        bias 
##   0.2317208   0.3966600   1.4491123   1.2036320  -0.1056484

# Validation data
cubPred.V <- matrix(NA, ncol = nbag, nrow = nrow(vDat))
cubiMat <- matrix(NA, nrow = nbag, ncol = 5)
for (i in 1:nbag) {
    fit_cubist <- readRDS(c.models[i])
    cubPred.V[, i] <- predict(fit_cubist, newdata = vDat)
    cubiMat[i, ] <- as.matrix(goof(observed = vDat$pH60_100cm, predicted = predict(fit_cubist, newdata = vDat)))
}
cubPred.V_mean <- rowMeans(cubPred.V)

cubiDat <- as.data.frame(cubiMat)
names(cubiDat) <- c("R2", "concordance", "MSE", "RMSE", "bias")
colMeans(cubiDat)

##          R2 concordance         MSE        RMSE        bias 
##  0.13384917  0.35375158  1.37133056  1.17048402  0.06049847

# Average validation MSE
avGMSE <- mean(cubiDat[, 3])
avGMSE

## [1] 1.371331
```

For the validation data, in addition to deriving the model diagnostic
statistics, we are also saving the actual model predictions for these
data for each iteration to the `cubPred.V` object. These will be used
further on for validating the prediction uncertainties.

The last line of the script above saves the mean of the mean square
error (MSE) estimates from the validation data. The independent MSE
estimator, accounts for both systematic and random errors in the
modeling. This estimate of the MSE is needed for quantifying the
uncertainties, as this error is in addition to that which are accounted
for by the bootstrap model, which are specifically those associated with
the deterministic model component i.e. the model relationship between
target variable and the covariates. Subsequently an overall prediction
variance (at each point or pixel) will be the sum of the random error
component (MSE) and the bootstrap prediction variance (as estimated from
the mean of the realisations from the bootstrap modeling).

<a href="#top">Back to top</a>

### Spatial mapping <a id="s-3"></a>

Our initial purpose here is to derive the mean and the variance of the
predictions from each bootstrap sample. This requires loading in each
bootstrap model, applying into the covariate data, then saving the
predicted map to file or R memory. In the case below the predictions are
saved to file. This is illustrated in the following script:

```r
### Note you will likely have different file path names ###
for (i in 1:nbag){
  fit_cubist<- readRDS(c.models[i])
  mapFile<- paste0(root,"maps/bootMap_", i, ".tif")
  
  predict(hunterCovariates_sub, # raster stack 
          fit_cubist, # model
          filename=mapFile, # export file
          format="GTiff", # file format
          overwrite=T)}
```

To evaluate the mean at each pixel from each of the created maps, the
base function `mean` can be applied to a given stack of rasters. First
we need to get the path location of the rasters. Notice from the
`list.files` function and the `pattern` parameter, we are restricting
the search of rasters that contain the string "bootMap". Next we make a
stack of those rasters, followed by the calculation of the mean, which
is also written directly to file.

```r
# Pathway to rasters Note you will likely have different file path names ###
files <- list.files(path = paste0(root, "maps/"), pattern = "bootMap", full.names = TRUE)

# Raster stack
r1 <- raster(files[1])
for (i in 2:length(files)) {
    r1 <- stack(r1, files[i])
}

# Calculate mean
meanFile <- paste0(root, "maps/meanPred.tif")
bootMap.mean <- writeRaster(mean(r1), filename = meanFile, format = "GTiff", overwrite = TRUE)
```

There is not a simple `R` function to use in order to estimate the
variance at each pixel from the prediction maps. Therefore we resort to
estimating it directly from the standard equation:

$Var(X) = \\frac{1}{1-n}\\sum\_{i=1}^{n}(x\_{i}-\\mu)^{2}$

The symbol *μ* in this case is the mean bootstrap prediction, and
*x*<sub>*i*</sub> is the *ith* bootstrap map. In the first step below,
we estimate the square differences and save the maps to file. Then we
calculate the sum of those squared differences, before deriving the
variance prediction. The last step is to add the variance of the
bootstrap predictions to the averaged MSE estimated from the validation
data.

```r
# Square differences
for (i in 1:length(files)) {
    r1 <- raster(files[i])
    diffFile <- paste0(root, "maps/bootAbsDif_", i, ".tif")
    jj <- (r1 - bootMap.mean)^2
    writeRaster(jj, filename = diffFile, format = "GTiff", overwrite = TRUE)
}

# calculate the sum of square differences Look for files with the bootAbsDif character string in file
# name
files2 <- list.files(path = paste0(root, "maps/"), pattern = "bootAbsDif", full.names = TRUE)
# stack
r2 <- raster(files2[1])
for (i in 2:length(files2)) {
    r2 <- stack(r1, files2[i])
}

sqDiffFile <- paste0(root, "maps/sqDiffPred.tif")
bootMap.sqDiff <- writeRaster(sum(r2), filename = sqDiffFile, format = "GTiff", overwrite = TRUE)


# Variance
varFile <- paste0(root, "maps/varPred.tif")
bootMap.var <- writeRaster(((1/(nbag - 1)) * bootMap.sqDiff), filename = varFile, format = "GTiff", overwrite = TRUE)

# Overall prediction variance
varFile2 <- paste0(root, "maps/varPredF.tif")
bootMap.varF <- writeRaster((bootMap.var + avGMSE), filename = varFile, format = "GTiff", overwrite = TRUE)
```

To derive to 90% prediction interval we take the square root of the
variance estimate and multiply that value by the quantile function value
that corresponds to a 90% probability. The *z* value is obtained using
the `qnorm` function. The result is then either added or subtracted to
the mean prediction in order to generate the upper and lower prediction
limits respectively.

```r
# Standard deviation
sdFile <- paste0(root, "maps/sdPred.tif")
bootMap.sd <- writeRaster(sqrt(bootMap.varF), filename = sdFile, format = "GTiff", overwrite = TRUE)

# standard error
seFile <- paste0(root, "maps/sePred.tif")
bootMap.se <- writeRaster((bootMap.sd * qnorm(0.95)), filename = seFile, format = "GTiff", overwrite = TRUE)


# upper prediction limit
uplFile <- paste0(root, "maps/uplPred.tif")
bootMap.upl <- writeRaster((bootMap.mean + bootMap.se), filename = uplFile, format = "GTiff", overwrite = TRUE)

# lower prediction limit
lplFile <- paste0(root, "maps/lplPred.tif")
bootMap.lpl <- writeRaster((bootMap.mean - bootMap.se), filename = lplFile, format = "GTiff", overwrite = TRUE)

# prediction interval range
pirFile <- paste0(root, "maps/pirPred.tif")
bootMap.pir <- writeRaster((bootMap.upl - bootMap.lpl), filename = pirFile, format = "GTiff", overwrite = TRUE)
```

As for the Universal kriging example, we can plot the associated maps of
the predictions and quantified uncertainties (Figure below)

```r
phCramp <- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598", "#abdda4", "#66c2a5", 
    "#3288bd", "#5e4fa2", "#542788", "#2d004b")
brk <- c(2:14)
par(mfrow = c(2, 2))
plot(bootMap.lpl, main = "90% Lower prediction limit", breaks = brk, col = phCramp)
plot(bootMap.mean, main = "Prediction", breaks = brk, col = phCramp)
plot(bootMap.upl, main = "90% Upper prediction limit", breaks = brk, col = phCramp)
plot(bootMap.pir, main = "Prediction limit range", col = terrain.colors(length(seq(0, 6.5, by = 1)) - 
    1), axes = FALSE, breaks = seq(0, 6.5, by = 1))
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/uncert_bootmaps.png" alt="rconsole">
    <figcaption> Soil pH predictions and prediction limits derived using bootstrapping.</figcaption>
</figure>


<a href="#top">Back to top</a>

### Validating the quantification of uncertainty <a id="s-4"></a>

You will recall the bootstrap model predictions on the validation data
were saved to the `cubPred.V` object. We want estimate the standard
deviation of those predictions for each point. Also recall that the
prediction variance is the sum of the MSE and the bootstrap models
prediction variance. Taking the square root of that summation results in
standard deviation estimate.

```r
val.sd <- matrix(NA, ncol = 1, nrow = nrow(cubPred.V))
for (i in 1:nrow(cubPred.V)) {
    val.sd[i, 1] <- sqrt(var(cubPred.V[i, ]) + avGMSE)}
```

We then need to multiply the standard deviation by the corresponding
percentile of the standard normal distribution in order to express the
prediction limits at each level of confidence. Note the use of the `for`
loop and the associated cycling through of the different percentile
values.

```r
# Percentiles of normal distribution
qp <- qnorm(c(0.995, 0.9875, 0.975, 0.95, 0.9, 0.8, 0.7, 0.6, 0.55, 0.525))

# zfactor multiplication
vMat <- matrix(NA, nrow = nrow(cubPred.V), ncol = length(qp))
for (i in 1:length(qp)) {
    vMat[, i] <- val.sd * qp[i]}
```

Now we add or subtract the limits to/from the averaged model predictions
to derive to prediction limits for each level of confidence.

```r
# upper prediction limit
uMat <- matrix(NA, nrow = nrow(cubPred.V), ncol = length(qp))
for (i in 1:length(qp)) {
    uMat[, i] <- cubPred.V_mean + vMat[, i]}

# lower prediction limit
lMat <- matrix(NA, nrow = nrow(cubPred.V), ncol = length(qp))
for (i in 1:length(qp)) {
    lMat[, i] <- cubPred.V_mean - vMat[, i]}
```

Now we assess the PICP for each level confidence. Recalling that we are
simply assessing whether the observed value is encapsulated by the
corresponding prediction limits, then calculating the proportion of
agreement to total number of observations.

```r
bMat <- matrix(NA, nrow = nrow(cubPred.V), ncol = length(qp))
for (i in 1:ncol(bMat)) {
    bMat[, i] <- as.numeric(vDat$pH60_100cm <= uMat[, i] & vDat$pH60_100cm >= lMat[, i])
}

colSums(bMat)/nrow(bMat)

##  [1] 0.98684211 0.97368421 0.96710526 0.92105263 0.84868421 0.63157895 0.43421053 0.20394737
##  [9] 0.10526316 0.05263158
```

As can be seen on the Figure below that there is an indication that the
prediction uncertainties could be a little too liberally defined, where
particularly at the higher level of confidence the associated PICP is
higher.

```r
# make plot
cs <- c(99, 97.5, 95, 90, 80, 60, 40, 20, 10, 5)  # confidence level
plot(cs, ((colSums(bMat)/nrow(bMat)) * 100))
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/PICP_boot.png" alt="rconsole">
    <figcaption> Plot of PICP and confidence level based on validation of bootstrapping model.</figcaption>
</figure>


Quantiles of the distribution of the prediction limit range are express
below for the validation data (in terms of the 90% level of confidence).
Compared to the universal kriging approach, the uncertainties quantified
from the bootstrapping approach are higher in general.

```r
cs <- c(99, 97.5, 95, 90, 80, 60, 40, 20, 10, 5)  # confidence level
colnames(lMat) <- cs
colnames(uMat) <- cs
quantile(uMat[, "90"] - lMat[, "90"])

##       0%      25%      50%      75%     100% 
## 3.871776 3.905907 3.930499 3.985198 4.300110
```

<a href="#top">Back to top</a>


### References <a id="s-5"></a>

Efron, B., and R. Tibshirani. 1993. *An Introduction to the Bootstrap*.
London: Chapman; Hall.

Liddicoat, C., D. Maschmedt, D. Clifford, R. Searle, T. Herrmann, L.M.
Macdonald, and J. Baldock. 2015. “Predictive Mapping of Soil Organic
Carbon Stocks in South Australia's Agricultural Zone.” *Soil Research*
53: 956–73.

Viscarra Rossel, R. A., C. Chen, M. J. Grundy, R. Searle, D. Clifford,
and P. H. Campbell. 2015. “The Australian Three-Dimensional Soil Grid:
Australia's Contribution to the Globalsoilmap Project.” *Soil Research*
53: 845–64.

<a href="#top">Back to top</a>