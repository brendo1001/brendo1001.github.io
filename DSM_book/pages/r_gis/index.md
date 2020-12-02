---
layout: page
title: Getting spatial in R
description: "generic GIS stuff for R"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-05-24
---


## Getting spatial in R

The following pages will introduce some basic concepts of using the `R` software for GIS operations. Nothing over the top but just a simple introduction to basic concepts like converting data to spatial objects, doing some spatial transformations, and data import and export of GIS data. `R` continues to enhance its GIS functionality, so it is likley the number of subpages will grow to try and illustrate these developments with digital soil science examples.

* [Basic GIS operations with point data]({{ site.url }}/DSM_book/pages/r_gis/pointpatterns/)
* [Basic GIS operations with raster data]({{ site.url }}/DSM_book/pages/r_gis/rasters/)
* [Raster resampling and reprojections]({{ site.url }}/DSM_book/pages/r_gis/reprojs/)
* [Interactive mapping with `leaflet`]({{ site.url }}/UseCases/Writings/interactivemap/)
* Interactive mapping with `mapview`
* [Raster clipping]({{ site.url }}/DSM_book/pages/r_gis/clipping/)


### Notes on using `R` for GIS stuff

`R` is richly served with functionality to work with, analyse,
manipulate and map spatial data. Many procedures one would carry out in
a GIS software, can more-or-less be performed (and automated) relatively
easy in `R`. The application of spatial data analysis in `R` is well
documented in Bivand, Pebesma, and Gomez-Rubio (2008). There you will
find a deep analysis with numerous examples of basic concepts right
through to quite advanced analyses. Similarly [Geocomputation with
R](https://geocompr.robinlovelace.net/) (with proper citation:
(Lovelace, Nowosad, and Muenchow 2019)) is a great resource and probably
demonstrates more of the recent developments and applications for doing
GIS work in `R`.

Naturally, in DSM, we constantly work with spatial data in one form or
another e.g., points, polygons, rasters. We need to to such things as
import, view, and export points to, in, and from a GIS. Similarly for
polygons and rasters.

Many of the functions used for working with spatial data do not come
with the base function suite installed with the `R` software. Thus we
need to use specific functions from a range of different contributed `R`
packages. Probably the most important and most frequently used are:

-   [`sp`](https://cran.r-project.org/web/packages/sp/index.html)
    contains many functions for handling vector (polygon) data.
-   [`raster`](https://cran.r-project.org/web/packages/raster/index.html)
    very rich source of functions for handling raster data.
-   [`rgdal`](https://cran.r-project.org/web/packages/rgdal/index.html)
    function for projections and spatial data I/O.

These 3 packages are more than able to do a very large suite of tasks.
Relatively newer packages like
[`sf`](https://cran.r-project.org/web/packages/sf/index.html) and
[`stars`](https://cran.r-project.org/web/packages/stars/index.html) are
increasingly popular packages for geospatial analyses of vector and
raster data respectively. Yet at the time of writing the author is less
familiar with these packages and what relative advantages they have over
their `sp` and `raster` counterparts. Currently most GIS functionality
needed for DSM can ably be done with with those packages mentioned
above, but note that applications involving more specialized GIS
functionality, handling and manipulating spatial-temporal data, and
working with data cubes, then perhaps the newer packages are going to
provide the required solutions. I will keep an eye on these packages
and determine whether a given DSM task can be better crafted with these
packages when the opportunity arises.

With regard to either `sp`, `raster`, `rgdal` (or any `R` package for
that matter), always consult the help files and online documentation
regarding these packages, and you will quickly realize that there is
deeper set of functionality that comes with the package that is not
covered in these pages.



References
----------

Bivand, R S, E J Pebesma, and V Gomez-Rubio. 2008. *Applied Spatial Data Analysis with R*. UseR! Series, Springer.

Lovelace, R, J Nowosad, and J Muenchow. 2019. *Geocomputation with R*. Chapman & Hall/CRC The R Series.













