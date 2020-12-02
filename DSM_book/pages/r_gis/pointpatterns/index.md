---
layout: page
title: Getting spatial in R
description: "generic GIS stuff for R"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-05-31
---


## Working with point patterns

Code is [here]({{ site.url }}/DSM_book/rcode/P3_1_RGIS.R)

We will be working with a small data set of soil information that was
collected from the Hunter Valley, NSW in 2010 called `HV100`. This data
set is contained in the `ithir` package. So first load it in:

```r
library(ithir)
data(HV100)
str(HV100)

## 'data.frame':    100 obs. of  6 variables:
##  $ site: Factor w/ 100 levels "a1","a10","a11",..: 1 2 3 4 5 6 7 8 9 10 ...
##  $ x   : num  337860 344060 347035 338235 341760 ...
##  $ y   : num  6372416 6376716 6372740 6368766 6366016 ...
##  $ OC  : num  2.03 2.6 3.42 4.1 3.04 4.07 2.95 3.1 4.59 1.77 ...
##  $ EC  : num  0.129 0.085 0.036 0.081 0.104 0.138 0.07 0.097 0.114 0.031 ...
##  $ pH  : num  6.9 5.1 5.9 6.3 6.1 6.4 5.9 5.5 5.7 6 ...
```

Now load the necessary R packages (you may have to install them onto
your computer first where you will need the `install.packages()`
function):

```r
library(sp)
library(raster)
library(rgdal)

## rgdal: version: 1.4-8, (SVN revision 845)
##  Geospatial Data Abstraction Library extensions to R successfully loaded
##  Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
##  Path to GDAL shared files: /usr/share/gdal/2.2
##  GDAL binary built with GEOS: TRUE 
##  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
##  Path to PROJ.4 shared files: (autodetected)
##  Linking to sp version: 1.3-2
```

Using the `coordinates` function from the `sp` package we can define
which columns in the data frame refer to actual spatial coordinates.
Here the coordinates are listed in columns `x` and `y`.

```r
coordinates(HV100) <- ~x + y
str(HV100)

## Formal class 'SpatialPointsDataFrame' [package "sp"] with 5 slots
##   ..@ data       :'data.frame':  100 obs. of  4 variables:
##   .. ..$ site: Factor w/ 100 levels "a1","a10","a11",..: 1 2 3 4 5 6 7 8 9 10 ...
##   .. ..$ OC  : num [1:100] 2.03 2.6 3.42 4.1 3.04 4.07 2.95 3.1 4.59 1.77 ...
##   .. ..$ EC  : num [1:100] 0.129 0.085 0.036 0.081 0.104 0.138 0.07 0.097 0.114 0.031 ...
##   .. ..$ pH  : num [1:100] 6.9 5.1 5.9 6.3 6.1 6.4 5.9 5.5 5.7 6 ...
##   ..@ coords.nrs : int [1:2] 2 3
##   ..@ coords     : num [1:100, 1:2] 337860 344060 347035 338235 341760 ...
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : chr [1:100] "1" "2" "3" "4" ...
##   .. .. ..$ : chr [1:2] "x" "y"
##   ..@ bbox       : num [1:2, 1:2] 335160 6365090 350960 6382816
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : chr [1:2] "x" "y"
##   .. .. ..$ : chr [1:2] "min" "max"
##   ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
##   .. .. ..@ projargs: chr NA
```

Note now that by using the `str` function, the class of `HV100` has now
changed from a `data.frame` to a `SpatialPointsDataFrame`. We can do a
spatial plot of these points using the `spplot` plotting function in the
`sp` package. There are a number of plotting options available, so it
will be helpful to consult the help file. Here we are plotting the SOC
concentration observed at each location.

```r
spplot(HV100, "OC", scales = list(draw = T), cuts = 5, col.regions = bpy.colors(cutoff.tails = 0.1, alpha = 1), cex = 1)
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/HV100_p.png" alt="rconsole">
    <figcaption> A plot of the site locations with reference to SOC concentration for the 100 points in the `HV100` data set.</figcaption>
</figure>


The `SpatialPointsDataFrame` structure is essentially the same data
frame, except that additional *spatial* elements have been added or
partitioned into slots. Some important ones being the bounding box (sort
of like the spatial extent of the data), and the coordinate reference
system (`proj4string`), which we need to define for our data set. To
define the CRS, we have to know some things about where our data are
from, and what was the corresponding CRS used when recording the spatial
information in the field. For this data set the CRS used is **WGS1984
UTM Zone 56**. To explicitly tell `R` this information we define the CRS
as a character string which describes a reference system in a way
understood by the [PROJ.4 projection library](https://proj.org/). An
interface to the PROJ.4 library is available in the `rgdal` package.
Alternative to using Proj4 character strings, we can use the
corresponding yet simpler EPSG codes (European Petroleum Survey Group).
`rgdal` also recognizes these codes. If you are unsure of the Proj4 or
EPSG code for the spatial data that you have, but know the CRS, you
should consult [Spatial Reference site](https://spatialreference.org/)
for assistance. The EPSG code for WGS1984 UTM Zone 56 is: 32556. So lets
define to CRS for this data.

```r
proj4string(HV100) <- CRS("+init=epsg:32756")
HV100@proj4string

## CRS arguments:
##  +init=epsg:32756 +proj=utm +zone=56 +south +datum=WGS84 +units=m
## +no_defs +ellps=WGS84 +towgs84=0,0,0
```

We need to define the CRS so that we can perform any sort of spatial
analysis. For example, we may wish to use these data in a GIS
environment such as Google Earth, ArcGIS, SAGA GIS etc. This means we
need to export the `SpatialPointsDataFrame` of `HV100` to an appropriate
spatial data format (for vector data) such as a shapefile or KML.
`rgdal` is again used for this via the `writeOGR` function. To export
the data set as a shapefile:

```r
writeOGR(HV100, ".", "HV_dat_shape", "ESRI Shapefile")
# Check yor working directory for presence of this file
```

Note that the object we wish to export needs to be a
`SpatialPointsDataFrame`. You should try opening up this exported
shapefile in a GIS software of your choosing.

To look at the locations of the data in Google Earth, we first need to
make sure the data is in the WGS84 geographic CRS. If the data is not in
this CRS (which is not the case for this data), then we need to perform
a coordinate transformation. This is facilitated by using the
`spTransform` function in `sp`. The EPSG code for WGS84 geographic is:
4326. We can then export out our transformed HV100 data set to a KML
file and visualize it in Google Earth.

```r
HV100.ll <- spTransform(HV100, CRS("+init=epsg:4326"))
writeOGR(HV100.ll, "HV100.kml", "ID", "KML")
# Check yor working directory for presence of this file
```

Sometimes to conduct further analysis of spatial data, we may just want
to import it into R directly. For example, read in a shapefile (this
includes both points and polygons too). So lets read in that shapefile
that was created just before and saved to the working directory,
`HV_dat_shape.shp`:

```r
imp.HV.dat <- readOGR("~/HV_dat_shape.shp")

## OGR data source with driver: ESRI Shapefile 
## Source: "~/HV_dat_shape.shp", layer: "HV_dat_shape"
## with 100 features
## It has 4 fields

imp.HV.dat@proj4string

## CRS arguments:
##  +proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs +ellps=WGS84
## +towgs84=0,0,0
```

The imported shapefile is now a `SpatialPointsDataFrame`, just like
`HV100` data that was worked on before, and is ready for further
analysis.

[Follow this link]({{ site.url }}/DSM_book/pages/r_gis/rasters/) to get a
basic introduction to working with raster data in `R`.
