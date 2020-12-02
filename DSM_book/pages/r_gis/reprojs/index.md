---
layout: page
title: Getting spatial in R
description: "generic GIS stuff for R"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-05-31
---


Reprojections, resampling and rasterisation
-------------------------------------------

A useful thing to do in `R` in the GIS context are the procedures around
resampling and reprojections. Such tasks are useful in the situation of
aligning spatial data to common resolutions and extents. For digital
soil mapping this is an important and regular task to perform. Similarly
rasterisation of polygon data is regularly performed. This page will
cover some know-how on how to do these varied tasks.

-   [Data preparation](#s-1)
-   [Resampling](#s-2)
-   [Simultaneous reprojection and resampling](#s-3)
-   [Reprojection and resolution change](#s-4)
-   [Polygon reprojection](#s-5)
-   [Polygon rasterisation](#s-6)

Code is available
[here]({{ site.url }}/DSM_book/rcode/resamplingRasters.R)

The specific data with which to do the exercises is found
[here]({{ site.url }}/DSM_book/data/reproj.zip)

Initialise the libraries that are needed

```r
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
```

### Data preparation <a id="s-1"></a>
In this first part we will be working with three raster layers, each
covering the same geographical area but have different projection
systems, resolutions and spatial extents. After you have downloaded the
data, you can use the following code to establish where they are located
and retrieve the metadata of each raster.

```r
files <- list.files("~", pattern = "tif$", full.names = T)
files

## [1] "~/20140509.B3.tif"
## [2] "~/elevation.tif"  
## [3] "~/GR_Th.tif"

# RASTER 1: remote sensing data
rs.raster <- raster(files[1])
rs.raster

## class      : RasterLayer 
## dimensions : 3026, 4037, 12215962  (nrow, ncol, ncell)
## resolution : 0.0002245788, 0.0002245788  (x, y)
## extent     : 149.863, 150.7696, -31.64765, -30.96807  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## source     : /~/20140509.B3.tif 
## names      : X20140509.B3

# RASTER 2: digital elevation model
elev.raster <- raster(files[2])
elev.raster

## class      : RasterLayer 
## dimensions : 54, 81, 4374  (nrow, ncol, ncell)
## resolution : 100, 100  (x, y)
## extent     : 1510462, 1518562, -3636821, -3631421  (xmin, xmax, ymin, ymax)
## crs        : +proj=lcc +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=134 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs 
## source     : /~/elevation.tif 
## names      : elevation 
## values     : 312.4171, 590.6609  (min, max)

# RASTER 3: Very granular gamma radiometrics data
gamma.raster <- raster(files[3])
gamma.raster

## class      : RasterLayer 
## dimensions : 606, 865, 524190  (nrow, ncol, ncell)
## resolution : 10, 10  (x, y)
## extent     : 1510418, 1519068, -3637349, -3631289  (xmin, xmax, ymin, ymax)
## crs        : +proj=lcc +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=134 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : /~/GR_Th.tif 
## names      : GR_Th 
## values     : 1.815541, 8.94882  (min, max)
```

    
<a href="#top">Back to top</a>

### Raster resampling <a id="s-2"></a>


The function to use here is `resample`. Here we want to get the
`elev.raster` to be the same resolution and extent to the
`gamma.raster`. Essentially going from a 100m grid cell to a 10m grid
cell. The resampling method used in bi-linear interpolation. The
alternative is nearest neighbor interpolation which is generally not
appropriate for numerical data, dependent on the context and use-case of
course.

Stacking rasters is a nice feature of `raster` as it confirms to the
user that a collection of rasters all have the same CRS, resolution and
extent. This is really important for doing digital soil mapping. When
rasters don’t stack, it means there is a problem, and one will have
difficulty in subsequent steps in the DSM workflow. The `stack` function
is the tool that we need. Also the `brick` function appears to do the
same sort of thing as `stack` too, but seems to be used more for
temporal data, or data stacks of the same provenance. `stack` appears to
be a generic function.

```r
# resample
rs.grid <- resample(x = elev.raster, y = gamma.raster, method = "bilinear")
rs.grid

## class      : RasterLayer 
## dimensions : 606, 865, 524190  (nrow, ncol, ncell)
## resolution : 10, 10  (x, y)
## extent     : 1510418, 1519068, -3637349, -3631289  (xmin, xmax, ymin, ymax)
## crs        : +proj=lcc +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=134 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : memory
## names      : elevation 
## values     : 312.4438, 590.6609  (min, max)

# stack
r3 <- stack(rs.grid, gamma.raster)
r3

## class      : RasterStack 
## dimensions : 606, 865, 524190, 2  (nrow, ncol, ncell, nlayers)
## resolution : 10, 10  (x, y)
## extent     : 1510418, 1519068, -3637349, -3631289  (xmin, xmax, ymin, ymax)
## crs        : +proj=lcc +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=134 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## names      :  elevation,      GR_Th 
## min values : 312.443825,   1.815541 
## max values :  590.66095,    8.94882
```

<a href="#top">Back to top</a>

### Simultaneous reprojection and resampling <a id="s-3"></a>

The function `projectRaster` is an incredibly useful function from the
`raster` package. As the name suggests it is used for changing data from
one projection system to another. This function also usefully does
resampling to by default where the raster (or stack of rasters) to be
processed is given the same CRS, resolution and extent as the target
raster (or stack of rasters). First, the default use case in
demonstrated, followed by a change to the target CRS but with a
resolution change.

If you recall from earlier, the `rs.grid` has the WGS1984 geographic
CRS: `+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0`,
where the grid cell have a resolution of about 22m, albeit expressed in
decimal degrees. The target raster is the `elev.raster` which has the
GDA94/ Geoscience Australia Lambert projection where the units are
expressed in meters. The resolution of this raster is 100m. Therefore in
this instance we do a reprojection and resample all in one step with the
following code. Note the use of nearest neighbor interpolation.

```r
# reproject remote sensing grid
pl.grid <- projectRaster(from = rs.raster, to = elev.raster, method = "ngb")

# stack
r4 <- stack(pl.grid, elev.raster)
r4

## class      : RasterStack 
## dimensions : 54, 81, 4374, 2  (nrow, ncol, ncell, nlayers)
## resolution : 100, 100  (x, y)
## extent     : 1510462, 1518562, -3636821, -3631421  (xmin, xmax, ymin, ymax)
## crs        : +proj=lcc +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=134 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs 
## names      : X20140509.B3,    elevation 
## min values :   0.05698202, 312.41711426 
## max values :    0.2888759,  590.6609497
```

Although both rasters above stack together you will note by plotting
each raster that the remote sensing raster appears has a rectangular
extent, yet the `elev.raster` is clipped to some boundary. Both rasters
actually have the same extent, but for the `elev.raster`, part of this
data extent has no data. This is because this data is just concerned
with a particular landholding and there is not any need to have the data
surrounding it. In the exercise concerned with [raster
clipping]({{ site.url }}/DSM_book/pages/r_gis/clipping/),
one can, if there is a requirement, to clip the `pl.grid` to the bounds
of the data in `elev.raster`.

<a href="#top">Back to top</a>


### Reprojection and resolution change <a id="s-4"></a>

Rather than set the target raster to the same properties as a source
raster, one can re-project to a common CRS, but set the resolution to
what is desired. Below the `rs.raster` to reprojected to the the same
CRS as the `elev.raster`, and outputted to 50m resolution (rather than
100m as is the source raster).

```r
# reproject and resample (50m pixels)
pl.grid50 <- projectRaster(from = rs.raster, crs = crs(elev.raster), method = "ngb", res = 50)
pl.grid50

## class      : RasterLayer 
## dimensions : 1711, 1898, 3247478  (nrow, ncol, ncell)
## resolution : 50, 50  (x, y)
## extent     : 1486689, 1581589, -3675366, -3589816  (xmin, xmax, ymin, ymax)
## crs        : +proj=lcc +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=134 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs 
## source     : memory
## names      : X20140509.B3 
## values     : -Inf, 0.5445645  (min, max)
```

<a href="#top">Back to top</a>


### Polygon reprojection <a id="s-5"></a>

Back in the work with [point patterns
data]({{ site.url }}/DSM_book/pages/r_gis/pointpatterns/)
you were shown how to change the CRS of `SpatialPointsDataFrames`. This
type of transformation can also be readily extended to spatial lines and
polygons too. Below, we will be working with a shapefile where the data
is given as polygons, and is in fact a legacy soil map for the same
geographic area as the raster data we were working with above. What we
will do is load the data, do a reprojection, and a rasterisation
procedure on this data. Ultimately for a digital soil mapping context we
might want to use polygon data as a predictive covariate. Therefore
these data need to be processed accordingly.

Now to load the data we use the `readOGR` function form the `sp`
package. You will note after import of the shapefile this data is
encoded as a `SpatialPolygonsDataFrame`. The data frame elements of this
polygon data contain the pertinent details of each polygon which in our
case is descriptive information of the soil type and landscape.

```r
poly.dat <- readOGR("/~/Soils_Curlewis_GDA94.shp")

## OGR data source with driver: ESRI Shapefile 
## Source: "/~/Soils_Curlewis_GDA94.shp", layer: "Soils_Curlewis_GDA94"
## with 354 features
## It has 6 fields

poly.dat

## class       : SpatialPolygonsDataFrame 
## features    : 354 
## extent      : 150.0011, 150.5011, -31.49843, -30.99843  (xmin, xmax, ymin, ymax)
## crs         : +proj=longlat +ellps=GRS80 +no_defs 
## variables   : 6
## names       :         NAME, LANDSCAPE, CODE,            LENGTH,        SHAPE_AREA,     PROCESS 
## min values  : BATTERY HILL,      AElo,   bh, 0.004701920115403,    3.82996751e-07,     AEOLIAN 
## max values  :     YARRAMAN,     TRwfa,   ya,  2.62094635880552, 0.031703676998096, TRANSFERRAL
```

Lets find out a bit more information about the `poly.dat` object i.e. the soil map.

```R
# Attribute table
head(poly.dat@data)

##              NAME LANDSCAPE CODE     LENGTH   SHAPE_AREA     PROCESS
## 0 KILPHYSICS ROAD      TRkr   kr 0.06258586 1.763738e-04 TRANSFERRAL
## 1      EAST LYNNE      COel   el 0.03153234 1.838048e-05   COLLUVIAL
## 2   LONG MOUNTAIN      RElm   lm 0.03033508 1.855672e-05    RESIDUAL
## 3  QUIRINDI CREEK      ALqc   qc 0.05039743 8.478940e-05    ALLUVIAL
## 4  QUIRINDI CREEK      ALqc   qc 0.02419802 2.233679e-05    ALLUVIAL
## 5       CONADILLY      ALcd   cd 0.03408230 3.911834e-05    ALLUVIAL

# soil type code and frequency
summary(poly.dat@data$CODE)

##  bh  bj  bo  ca  cd  cr  cu  dh  el  fr  gi  gl  go  gy  ha  kr  lg lga  lm  lo 
##  18  26   9  10  16  12   1   2  12  12   6   4  16   3   2   1   2   2  13  14 
##  lr  ma  md  mm  mn  mo  mt  mw  nj  ph  pn  po  qc  sg  ta  tf  tu  wa wfa  xx 
##   3   1   1  17   2   4   6   2   9  12  10   8  13  29   5   7  11  10   1  21 
##  ya 
##   1

summary(as.factor(as.numeric(poly.dat@data$CODE)))  # numeric factor

##  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 
## 18 26  9 10 16 12  1  2 12 12  6  4 16  3  2  1  2  2 13 14  3  1  1 17  2  4 
## 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 
##  6  2  9 12 10  8 13 29  5  7 11 10  1 21  1

# Basic plot plot(poly.dat) invisible(text(getSpPPolygonsLabptSlots(poly.dat),
# labels = as.character(poly.dat@data$CODE), cex = 0.4))

# coordinate reference system
crs(poly.dat)

## CRS arguments: +proj=longlat +ellps=GRS80 +no_defs
```

Currently the data is in GDA94 CRS:
`+proj=longlat +ellps=GRS80 +no_defs`, and we want to have it in the
project GDA94 Lambert system as for the rasters that were processed
above.

```r
## Reproject to new projection (newProj)
newProj <- "+proj=lcc +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=134 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs"
poly.dat.T <- spTransform(poly.dat, CRSobj = newProj)
class(poly.dat.T)

## [1] "SpatialPolygonsDataFrame"
## attr(,"package")
## [1] "sp"
```

To confirm this worked we can plot the remote sensing grid (`pl.grid50`)
and overlay the polygon data.

```r
plot(pl.grid)
plot(poly.dat.T, add = T)
invisible(text(getSpPPolygonsLabptSlots(poly.dat.T), labels = as.character(poly.dat.T@data$CODE), cex = 1.2))
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/soil_map_raster.png" alt="rconsole">
    <figcaption> Gridded remote sensing data overlayed with soil map polygons. Each data source have the same CRS.</figcaption>
</figure>

<a href="#top">Back to top</a>

### Rasterisation <a id="s-6"></a>

The function we need here is `rasterize` from the `raster` package. Here
we will rasterise the `CODE` variable of the polygon data, and fit it to
the same resolution and extent as the `pl.grid50` remote sensing data.

```r
# rasterise
poly.raster <- rasterize(poly.dat.T, pl.grid50, field = "CODE")
names(poly.raster) <- "soil_map_CODE"

# stack
r5 <- stack(pl.grid50, poly.raster)
r5

## class      : RasterStack 
## dimensions : 1711, 1898, 3247478, 2  (nrow, ncol, ncell, nlayers)
## resolution : 50, 50  (x, y)
## extent     : 1486689, 1581589, -3675366, -3589816  (xmin, xmax, ymin, ymax)
## crs        : +proj=lcc +lat_1=-18 +lat_2=-36 +lat_0=0 +lon_0=134 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs 
## names      : X20140509.B3, soil_map_CODE 
## min values :         -Inf,             1 
## max values :    0.5445645,    41.0000000
```

Plotting rasters in `R` is easily facilitated with the `plot()`
function, and is hackable in terms of customising legends, titles and
other graphical features. Experience of using this function for
categorical data like we have just created in `poly.raster` does not
result in very nice looking maps. The approach to map categorical
variables in `R` nicely can be done via `levelplot` from the `rasterVis`
package. The below code is a generic one to use to display categorical
maps.

```r
# plot rasterised polygon
r2 <- as.factor(r2)
rat <- levels(r2)[[1]]

# Match raster levels to polygon code
m1 <- c(as.matrix(levels(r2)[[1]]))
m2 <- levels(poly.dat@data$CODE)[m1]
rat[["code"]] <- c(m2)
levels(r2) <- rat

# plot
rasterVis::levelplot(r2, xlab = "", ylab = "")
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/rasterised_soilmap.png" alt="rconsole">
    <figcaption> Rasterised soil map created using the `levelplot` function. This function is more suitable to use for raster mapping in particular in instances of working with categorical data.</figcaption>
</figure>


<a href="#top">Back to top</a>