---
layout: page
title: Getting spatial in R
description: "generic GIS stuff for R"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-05-31
---


## Working with raster data

Code is [here]({{ site.url }}/DSM_book/rcode/P3_1_RGIS.R)

Most of the functions needed for handling raster data are contained in
the `raster` package. There are functions for reading and writing raster
files from and to different raster formats. In DSM we work quite a deal
with data in table format and then rasterise this data so that we can
make a map. To do this in `R`, lets bring in a `data.frame`. This could
be either from a text-file, but as for the previous occasions, the data
is imported from the `ithir` package. This data is a digital elevation
model with 100m grid resolution, from the Hunter Valley, NSW, Australia.
The same area where the data point pattern used in the [point patterns
page](%7B%7B%20site.url%20%7D%7D/DSM_book/pages/r_gis/pointpatterns/)
originated from.

```r
library(ithir)
data(HV_dem)
str(HV_dem)

## 'data.frame':    21518 obs. of  3 variables:
##  $ X        : num  340210 340310 340110 340210 340310 ...
##  $ Y        : num  6362640 6362640 6362740 6362740 6362740 ...
##  $ elevation: num  177 175 178 172 173 ...
```

As the data is already a *raster* (such that the row observation
indicate locations on a regular spaced grid), but in a table format, we
can just use the `rasterFromXYZ` function from `raster`. Also we can
define the CRS just like we did with the `HV100` point data we worked
with [before]({{ site.url }}/DSM_book/pages/r_gis/pointpatterns/).

```r
r.DEM <- rasterFromXYZ(HV_dem[, 1:3])
crs(r.DEM) <- "+init=epsg:32756"
r.DEM

## class      : RasterLayer 
## dimensions : 215, 169, 36335  (nrow, ncol, ncell)
## resolution : 100, 100  (x, y)
## extent     : 334459.8, 351359.8, 6362590, 6384090  (xmin, xmax, ymin, ymax)
## crs        : +init=epsg:32756 +proj=utm +zone=56 +south +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
## source     : memory
## names      : elevation 
## values     : 29.61407, 315.6837  (min, max)
```

So lets do a quick plot of this raster and overlay the `HV100` point
locations. (Note you will have needed to process the `HV100` data
accordingly as per the [point patterns page]({{ site.url }}/DSM_book/pages/r_gis/pointpatterns/) to show this figure).

```r
plot(r.DEM)
points(HV100, pch = 20)
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/HV_demP.png" alt="rconsole">
    <figcaption> Digital elevation model for the Hunter Valley, overlayed with the `HV100` sampling sites.</figcaption>
</figure>


So we may want to export this raster to a suitable format for further
work in a standard GIS environment. See the help file for `writeRaster`
to get information regarding the supported grid types that data can be
exported. For demonstration, we will export our data to ESRI Ascii
ascii, as it is a common and universal raster format.

```r
writeRaster(r.DEM, filename = "~/HV_dem100.asc", format = "ascii", overwrite = TRUE)
```

What about exporting raster data to KML file? Here you could use the KML
function. Remember that we need to reproject our data because it is in
the UTM system, and need to get it to WGS84 geographic. The raster
re-projection is performed using the `projectRaster` function. Look at
the help file for this function. Probably the most important parameters
are `crs`, which takes the CRS string of the projection you want to
convert the existing raster to, assuming it already has a defined CRS.
The other is `method` which controls the interpolation method. For
continuous data, *bilinear* would be suitable, but for categorical,
*ngb*, (which is nearest neighbor interpolation) is probably better
suited. Some more information and applications of the `projectRaster`
function can be found in the [Raster resampling and
reprojections]({{ site.url }}/DSM_book/pages/r_gis/reprojs/)
page. `KML` is a handy function from `raster` for exporting grids to kml
format.

```r
p.r.DEM <- projectRaster(r.DEM, crs = "+init=epsg:4326", method = "bilinear")
KML(p.r.DEM, "HV_DEM.kml", col = rev(terrain.colors(255)), overwrite = TRUE)
# Check yor working directory for presence of the kml file
```

Now visualize this in Google Earth and overlay this map with the points
that were created before.

The other useful procedure we can perform is to import rasters directly
into `R` so we can perform further analyses. `rgdal` interfaces with the
GDAL library, which means that there are [many supported grid formats
that can be read into `R`](https://gdal.org/drivers/raster/index.html).
Here we will load in `HV_dem100.asc` raster that was made just before.

```r
read.grid <- readGDAL("~/HV_dem100.asc")

## ~/HV_dem100.asc has GDAL driver AAIGrid 
## and has 215 rows and 169 columns
```

The imported raster `read.grid` is a `SpatialGridDataFrame`, which is a
formal class of the `sp` package. To be able to use the raster functions
from `raster` we need to convert it to the `RasterLayer` class. This is
not exactly a conversion, rather just using the `raster` function to
read in the `read.grid` file. Although, the `raster` function does do a
conversion from `SpatialGridDataFrame` to `RasterLayer` with this
function too.

```r
grid.dem <- raster("~/HV_dem100.asc")
grid.dem

## class      : RasterLayer 
## dimensions : 215, 169, 36335  (nrow, ncol, ncell)
## resolution : 100, 100  (x, y)
## extent     : 334459.8, 351359.8, 6362590, 6384090  (xmin, xmax, ymin, ymax)
## crs        : NA 
## source     : In Memory 
## names      : HV_dem100
```

You will notice from the `R` generated output indicating the data
source, it says it is loaded into memory. This is fine for small
rasters, but can become a problem when very large rasters need to be
handled. A really powerful feature of the `raster` package is the
ability to point to the location of a raster/s without the need to load
it into memory. It is only very rarely that one needs to use all the
data contained in a raster at one time. As will be seen later on, this
useful feature makes for a very efficient way to perform digital soil
mapping across very large spatial extents.

