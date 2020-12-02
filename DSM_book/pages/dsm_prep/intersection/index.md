---
layout: page
title: Preparatory and exploratory analysis for digital soil mapping
description: ""
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-06-18
---


## Intersecting soil point observations with environmental covariates


In order to carry out digital soil mapping in terms of evaluating the
significance of environmental variables in explaining the spatial
variation of the target soil variable under investigation, we need to
link both sets of data together and extract the values of the covariates
at the locations of the soil point data.

The first task is to bring in to our working environment some soil point
data. We will be using a data set of soil samples collected from the
Hunter Valley, NSW Australia. The area in question is an approximately
22*k**m*<sup>2</sup> sub-area of the Hunter Wine Country Private
Irrigation District (HWCPID), situated in the Lower Hunter Valley, NSW
([32.8329S,151.354E](https://www.google.com.au/maps/place/32%C2%B049'58.4%22S+151%C2%B021'14.4%22E/@-32.7833933,151.2510364,12.63z/data=!4m5!3m4!1s0x0:0x0!8m2!3d-32.8329!4d151.354)).
The HWCPID is approximately 140 km north of Sydney, NSW, Australia. The
target variable is soil pH. The data was preprocessed such that the
predicted values are outputs of the [mass-preserving depth
function]({{ site.url }}/DSM_book/pages/dsm_prep/splines/).
You will find that most examples in this section and other sections of
this course that this data set is used quite a bit. The data is loaded
in from the `ithir` package with the following script:

```r
library(ithir)
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
```

As you will note, there are 506 observations of soil pH. These data are
associated with a spatial coordinate and also have associated
environmental covariate data that have been intersected with the point
data. The environmental covariates have been sourced from a digital
elevation model and Landsat 7 satellite data. For the demonstration
purposes of the exercise, we will firstly remove this already
intersected data and start fresh - essentially this is an opportunity to
recall earlier work on [dataframe manipulation and
indexing]({{ site.url }}/DSM_book/pages/r_literacy/part5/).

```r
# round pH data to 2 decimal places
HV_subsoilpH$pH60_100cm <- round(HV_subsoilpH$pH60_100cm, 2)

# remove already intersected data
HV_subsoilpH <- HV_subsoilpH[, 1:3]

# add an id column
HV_subsoilpH$id <- seq(1, nrow(HV_subsoilpH), by = 1)

# re-arrange order of columns
HV_subsoilpH <- HV_subsoilpH[, c(4, 1, 2, 3)]

# Change names of coordinate columns
names(HV_subsoilpH)[2:3] <- c("x", "y")
```

Also in the `ithir` package are a collection of rasters that correspond
to environmental covariates that cover the extent of the just loaded
soil point data. These can be loaded using the script:

```r
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

This data set is a stack of 11 `rasterLayers` which correspond to mainly
indices derived from a digital elevation model: elevation(`elevation`),
terrain wetness index (`TWI`), altitude above channel network (`AACN`),
terrain ruggedness index (`Terrain_Ruggedness_Index`), hillshading
(`Hillshading`), incoming solar radiation (`Light_insolation`),
mid-slope position (`Mid_Slope_Positon`), multi-resolution valley bottom
flatness index (`MRVBF`), and slope gradient (`Slope`). Landsat 7
satellite spectral data, specifically band 1 (`Landsat_Band1`} and
normalised difference vegetation index (`NDVI`) are provided too, and
give some indication of the spatial variation of vegetation patterns
across the study area.

You may notice that there is a commonality between these `rasterlayers`
in terms of their CRS, dimensions and resolution. When you have multiple
`rasterlayers` as individual rasters, but they are common to each other
in terms of resolution and extent, rather than working with each raster
independently it is much more efficient to stack them all into a single
object. The `stack` function from the `raster` package is ready-made for
this, of which the `hunterCovariates_sub` stack is an output. This
harmony is an ideal situation for DSM where there may often be instances
where rasters from the some area under investigation may have different
resolutions, extents and even CRSs. It these situations it is common to
reproject and or resample to a common projection and resolution. The
functions from the `raster` package which may be of use in these
situations are `projectRaster` and `resample`. The [Reprojections,
resampling and rasterisation]({{ site.url }}/DSM_book/pages/r_gis/reprojs/)
page takes you through a number of different scenarios and workflows
using these functions and others.

While the example is a little contrived, it is useful to always
determine whether or not the available covariates have complete coverage
of the soil point data. This might be done with the following script
which will produce a map like in the figure below.

```r
# plot raster
plot(hunterCovariates_sub[["Elevation"]], main = "Hunter Valley elevation map with overlayed point locations")

## plot points
coordinates(HV_subsoilpH) <- ~x + y
plot(HV_subsoilpH, add = T)
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/hunterValley1.png" alt="rconsole">
    <figcaption> unter Valley elevation map with the soil point locations overlayed upon it.</figcaption>
</figure>


With the soil point data and covariates prepared, it is time to perform
the intersection between the soil observations and covariate layers
using the script:

```r
coordinates(HV_subsoilpH) <- ~x + y
DSM_data <- extract(x = hunterCovariates_sub, y = HV_subsoilpH, sp = 1, method = "simple")
```

The `extract` function is quite useful. Essentially the function ingests
the `rasterStack` object, together with the `SpatialPointsDataFrame`
object `HV_subsoilpH`. The `sp` parameter set to 1 means that the
extracted covariate data gets appended to the existing
`SpatialPointsDataFrame` object. While the `method` object specifies the
extraction method which in our case is *simple* which likened to get the
covariate value nearest to the points i.e it is likened to *drilling
down*.

A good practice is to then export the soil and covariate data intersect
object to file for later use. First we convert the spatial object to a
`data.frame`, then export as a comma separated file.

```r
DSM_data <- as.data.frame(DSM_data)
write.csv(DSM_data, "hunterValley_SoilCovariates_pH.csv", row.names = FALSE)
```

In the previous example the rasters we wanted to use are available data
from the `ithir` package. More generally we will have the raster data we
need sitting on our computer, a USB or even on the cloud somewhere. The
steps for intersecting the soil observation data with the covariates are
the same as before, except we now need to specify the location where our
raster covariate data is located. We need not even have to load in the
rasters to memory, just point `R` to where they are, and then run the
raster `extract` function. This utility is obviously a very handy
feature when we are dealing with an inordinately large or large number
of rasters. The workhorse function we need is `list.files`. First you
will need to download the [testGrids.zip]({{ site.url }}/DSM_book/data/testGrids.zip)
folder, and unzip them into a directory of your choosing. Now try the
following script:

```r
list.files(path = "~/testGrids", pattern = "\\.tif$", full.names = TRUE)

##  [1] "~/AACN.tif"                    
##  [2] "~/Elevation.tif"               
##  [3] "~/Hillshading.tif"             
##  [4] "~/Landsat_Band1.tif"           
##  [5] "~/Light_insolation.tif"        
##  [6] "~/Mid_Slope_Positon.tif"       
##  [7] "~/MRVBF.tif"                   
##  [8] "~/NDVI.tif"                    
##  [9] "~/Slope.tif"                   
## [10] "~/Terrain_Ruggedness_Index.tif"
## [11] "~/TWI.tif"
```

The parameter `path` is essentially the directory location where the
raster files are sitting. If needed, we may also want to do recursive
listing into directories that are within that path directory. We want
`list.files()` to return all the files (in our case) that have the
*.tif* extension. This criteria is set via the `pattern` parameter, such
that `$` at the end means that this is end of string, and but adding
`\\`. ensures that you match only files with extension *.tif*, otherwise
it may list (if they exist), files that end in *.atif* as an example.
You may guess that any other type of pattern matching criteria could be
used to suit your own specific data. The `full.names` logical parameter
is just a question of whether we want to return the full pathway address
of the raster file, in which case, we do.

All we then need to do is perform a raster stack of these individual
rasters, then perform the intersection. This is really the handy feature
where to perform the stack, we still need not require the loading of the
rasters into the R memory. They are still on file!.

```r
files <- list.files(path = "~/testGrids", pattern = "\\.tif$", full.names = TRUE)

# stack rasters
r1 <- raster(files[1])
for (i in 2:length(files)) {
    r1 <- stack(r1, files[i])}
r1

## class      : RasterStack 
## dimensions : 249, 210, 52290, 11  (nrow, ncol, ncell, nlayers)
## resolution : 25, 25  (x, y)
## extent     : 338422.3, 343672.3, 6364203, 6370428  (xmin, xmax, ymin, ymax)
## crs        : +proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
## names      :        AACN,   Elevation, Hillshading, Landsat_Band1, Light_insolation, Mid_Slope_Positon,       MRVBF,        NDVI,       Slope, Terrain_Ruggedness_Index,         TWI 
## min values :    0.000000,   72.217499,    0.000677,     26.000000,      1236.662840,          0.000009,    0.000002,   -0.573034,    0.001708,                 0.194371,    8.224325 
## max values :  106.665482,  212.632507,   32.440960,    140.000000,      1934.199950,          0.956529,    4.581594,    0.466667,   21.809752,                15.945321,   20.393652
```

Note that the stacking of rasters can only be possible if they are all
equivalent in terms of resolution and extent. The [Reprojections,
resampling and rasterisation]({{ site.url }}/DSM_book/pages/r_gis/reprojs/)
page takes you through a number of different scenarios and workflows for
getting your data layers all harmonised. With the stacked rasters, we
can perform the soil point data intersection as done previously.

```r
DSM_data <- extract(r1, HV_subsoilpH, sp = 1, method = "simple")
```
