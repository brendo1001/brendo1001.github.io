---
layout: page
title: R packages
description: "another list"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-05-24
---


## Some `R` packages that are useful for digital soil mapping

Notwithstanding to the rich statistical and analytical resource provide through the `R` base functionality, the following `R` packages (and their contained functions) are what I think are an invaluable resource for doing digital soil mapping. 

There are four main groups of tasks that are critical for implementing DSM in general. These are:

1. [Soil science and pedometric type tasks](#s-1)
2. [Using GIS tools and related GIS tasks](#s-2)
3. [Calibrating models](#s-3)
4. [Making maps, plotting etc.](#s-4)

The following are short introductions about those packages that fall into these categories.

### Soil science and pedometrics <a id="s-1"></a>

* Various `R` packages and `R` functions that i have had a hand in developing can be found on the [software page of this website]({{ site.url }}/software/).

* `ithir`: Soil data and functions. [A necessary `R` package]({{ site.url }}/DSM_book/pages/ithir/) to have for following the R workflows throughout these pages dedicated to doing digital soil mapping with `R`.

* `aqp`: [Algorithms for quantitative pedology](http://cran.r-project.org/web/packages/aqp/index.html). A collection of
algorithms related to modeling of soil resources, soil classification, soil profile aggregation, and visualization.

* `GSIF`: [Global soil information facility](http://cran.r-project.org/web/packages/GSIF/index.html). Tools, functions and sample datasets for digital soil mapping.

<a href="#top">Back to top</a>


### GIS stuff <a id="s-2"></a>

* `sp` is a highly useful [package](http://cran.r-project.org/web/packages/sp/index.html) that provides classes and methods for spatial data. The classes document where the spatial location information resides, for 2D or 3D data. Utility functions are provided, e.g. for plotting data as maps, spatial selection, as well as methods for retrieving coordinates, for sub-setting, print, summary, etc.

* [`raster`](http://cran.r-project.org/web/packages/raster/index.html). Reading, writing, manipulating, analyzing and modeling of gridded spatial data. The package implements basic and high-level functions and processing of very large files is supported.

* [`rgdal`](http://cran.r-project.org/web/packages/rgdal/index.html) provides bindings to Frank Warmerdam's Geospatial Data Abstraction Library (GDAL) (>= 1.6.3) and access to projection/transformation operations from the PROJ.4 library. Both GDAL raster and OGR vector map data can be imported into `R`, and GDAL raster data and OGR vector data exported. Use is made of classes defined in the `sp` package.

* [`RSAGA`](http://cran.r-project.org/web/packages/RSAGA/index.html) provides access to geocomputing and terrain analysis functions of [SAGA GIS](http://www.saga-gis.org/en/index.html) from within `R` by running the command line version of SAGA. `RSAGA` furthermore provides several `R` functions for handling ASCII grids, including a flexible framework for applying local functions (including predict methods of fitted models) and focal functions to multiple grids.

<a href="#top">Back to top</a>


### Modelling <a id="s-3"></a>

* [`caret`](http://cran.r-project.org/web/packages/caret/index.html) has an extensive range of functions for training and plotting classification and regression models. See the [caret website](http://topepo.github.io/caret/index.html) for more detailed information. 

* [`Cubist`](http://cran.r-project.org/web/packages/Cubist/index.html) does regression modeling using rules with added instance-based corrections. Cubist models were developed by Ross Quinlan. Further information can be found at [Rulequest](https://www.rulequest.com/) 

* [`C5.0`](http://cran.r-project.org/web/packages/C50/index.html) does C5.0 decision trees and rule-based models for pattern recognition. Another model structure developed by Ross Quinlan.

* [`gam`](http://cran.r-project.org/web/packages/gam/index.html) has functions for fitting and working with generalized additive models.

* [`nnet`](http://cran.r-project.org/web/packages/nnet/index.html) is software for feed-forward neural networks with a single hidden layer, and for multinomial log-linear models.

* [`gstat`](http://cran.r-project.org/web/packages/gstat/) is for doing geostatistics. Variogram modelling, simple, ordinary and universal point or block (co)kriging, sequential Gaussian or indicator (co)simulation; variogram and variogram map plotting utility functions. A related and useful package is [`automap`](http://cran.r-project.org/web/packages/automap/index.html), which performs an automatic interpolation by automatically estimating the variogram and then calling `gstat`.

<a href="#top">Back to top</a>


### Mapping and plotting <a id="s-4"></a>

* Both `raster` and `sp` have handy functions for plotting spatial data. Besides using the base plotting functionality, another useful plotting package is [`ggplot2`](http://cran.r-project.org/web/packages/ggplot2/index.html). This package is an implementation of the grammar of graphics in `R`. It combines the advantages of both base and lattice graphics: conditioning and shared axes are handled automatically, and you can still build up a plot step by step from multiple data sources. It also implements a sophisticated multidimensional conditioning system and a consistent interface to map data to aesthetic attributes. See the [ggplot2 website](http://ggplot2.org/) for more information, documentation and examples.

<a href="#top">Back to top</a>