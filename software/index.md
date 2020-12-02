---
layout: page
title: Software
description: "Software"
header-img: images/NZ1.jpg
comments: false
modified: 2016-11-16
---

Scientific software development plays a very important role in research. The software described below are coded mostly in R.

### Disclaimer
In the development of the software described below, care has been taken to ensure each is operationally sound. However, they are available and supplied 'as is' and no warranty is provided or implied. 



### What's available..

* [ithir](#s-1)
* [DSMART](#s-2)
* [OSPATS](#s-3)
* [Fuzme](#s-4)
* [Dissever](#s-5)
* [Tools for optimal sampling](#s-6)
* [Tangles](#s-7)




## ithir <a id="s-1"></a>
-----

ithir is an R package that was initiated with the objective of providing a home to a suite of functions that would be of use to soil scientists and pedometricians. In its current version, it contains a few useful functions, but is more  a home to a variety of soil and related soil information data sets that are used in the [Using R for Digital Soil Mapping](http://www.springer.com/gp/book/9783319443256) book. Consequently, the package is now more-or-less a companion to that book if you want to complete the many examples that are contained therein. 

### Features


* Lots of varied soil and related soil information data sets. Different types of soil variable data. Different file formats: data frames, rasters etc.

* A couple of useful functions. Namely the equal-area smoothing spline (ea_spline) that is described in [Bishop et al. (1999)](http://www.sciencedirect.com/science/article/pii/S0016706199000038) and implemented within a digital soil maping context in [Malone et al. 2009]({{ site.url }}/downloads/journal/malone2009_2.pdf). This function is useful for harmonizing soil profile data and lets you return values from the observed data at standardized depth intervals. 

* There are a couple of little specialized plotting functions that helps you plot useful outputs from the spline fitting function. These are very basic and a bit buggy (Need to generalist these functions a bit more).


* Functions for goodness of fit statistics for both continuous (goof) and categorical data (goofcat)

* Clear documentation and examples about how to use each of the datasets and functions are automatically provided once the package is installed. 

### Useful Links

* [ithir source code](https://bitbucket.org/brendo1001/ithir/). This repository will also give instructions on how to install this package into your R environment. 

<a href="#top">Back to top</a>




## DSMART <a id="s-2"></a>
-----

DSMART means: Disaggregation and Harmonisation of Soil Map Units Through Resampled Classification Trees. [Odgers et al. (2014)](http://www.sciencedirect.com/science/article/pii/S0016706113003522)  provide a detailed explanation of the DSMART algorithm. The aim of DSMART is to predict the spatial distribution of soil classes by disaggregating the soil map units of a soil polygon map. Here soil map units are soil map are entities consisting of a defined set of soil classes which occur together in a certain spatial pattern and in an assumed set of proportions. The DSMART method of representing the disaggregated soil class distribution is as a set of numerical raster surfaces, with one raster per soil class. The data representation for each soil class is given as the probability of occurrence. In order to generate the probability surfaces, a re-sampling approach is used to generate *n* realizations of the potential soil class distribution within each map unit. Then at each grid cell, the probability of occurrence of each soil class is estimated by the proportion of times the grid cell is predicted as each soil class across the set of realizations. The procedure of the DSMART algorithm can be summarized in 6 main steps:

1. Draw *n* random samples from each soil map polygon. 

2. Assign soil class to each sampling point.

    * Weighted random allocation from soil classes in relevant map unit
    
    * Relative proportions of soil classes within map units are used as the weights
    
3. Use sampling points and intersected covariate values to build a decision tree to predict spatial distribution of soil classes.

4. Apply decision tree across mapping extent using covariate layers.

5. Steps 1-4 repeated *i* times to produce *i* realizations of soil class distribution. 

6. Using *i* realizations generate probability surfaces for each soil class.

The DSMART algorithm has been coded in C++ originally by Sun Wei (China), and then by Nathan Odgers (Australia) in Python who has also done some things with it in R as well. It is now available as a stand alone R package, where the DSMART algorithm is implemented in 2 steps or functions. The first function (dsmart) does the classification tree stuff and associated soil class prediction. The dsmartr function generates the probability rasters by aggregating outputs from the dsmart function. 

### Useful Links

* [dsmart source code](https://bitbucket.org/brendo1001/dsmart/). This repository will also give instructions on how to install this package into your R environment. Once installed the documentation and provided examples will help you get the algorithm running and understanding of the required inputs. 

<a href="#top">Back to top</a>


## OSPATS <a id="s-3"></a>
-----

*OSPATS* means optimized stratification and allocation for design-based estimation of spatial means using predictions with error. It was introduced by [de Gruijter et al. 2015](https://jssam.oxfordjournals.org/content/3/1/19.abstract) to solve the problem of deriving spatial strata in consideration of underlying uncertainty. The context here is that if we want to estimate the spatial means of some target variable, lets say soil carbon because we want to perform an on farm audit. Design-based sampling and inference is usually recommended here because the sampling locations are selected by probability sampling, resulting in the inference or estimation being based on the sampling design used to select the sampling locations. The benefit of this is that the subsequent inference is unbiased and free of any model-based assumptions. Stratified simple random sampling is generally the most useful because we can increase the sampling efficiency. However, by what variables do we stratify. We could used compact geographical stratification for example, or we may cluster together a suite of environmental covariates, or we may have a map of our target variable and derive stratifications from that. We could consider these three examples as existing along a gradient of what we know about the target variable from lowest to highest. 

*OSPATS*, by taking into account the prediction variations is able to produce stratifications that represent transitions between knowing nothing about soil carbon variation (high mapping uncertainty) and knowing a lot about soil carbon variation(low mapping uncertainty) situations. Given an initial stratification solution - such as that derived from stratification of a map assuming values are error-free, through an iterative reallocation, grid points are assigned/re-assigned to strata of which there are a specified number. An objective function *O* is then estimated from this stratification. *O* can more-or-less be interpreted as sampling variance for that stratification which takes into account the prediction variances of the values that in turn needs to be minimized (via iteration). Pending further rounds of re-allocation and estimation of *O*, iteration stops until it is minimized, the result being an optimal stratification of the target area. 

A useful feature of using *Ospats* is that we can derived both optimally, the recommended number of strata and sample for a target area. This takes a lot of the guess work out of the process. Furthermore if we were to enter into a monitoring system we could also theoretically re-run *Ospats* at each assessment period. This would result in new strata and samples for each campaign, which would circumvent an possibility of the system being gamed if monitoring sites remained fixed in space. The optimizing features, plus the circumvention of gaming make *Ospats* a robust mechanism for auditing phenomena across space and through time. Of particular note here is in soil carbon auditing and monitoring programs.  

### Useful Links

* Source code is not openly available because the *Ospats* algorithm is subject to a [Patent](http://www.google.com.na/patents/WO2011150472A1?cl=en).

* [An Example]({{site.url }}/downloads/journal/malone2016_2.pdf) of using *Ospats* for on farm soil carbon auditing.

* [Background](http://link.springer.com/chapter/10.1007%2F978-3-319-04084-4_6) on soil carbon monitoring networks.

<a href="#top">Back to top</a>


## Fuzme <a id="s-4"></a>
-----

Fuzme is an R package for calculation of Fuzzy k-means with/without extragrades. I wanted to integrate fuzzy-k means into my R workflow so i translated some of Budiman Minansy's matlab code into R. The R version of Fuzzy k-means with extragrades is a little buggy. The [FuzME](http://sydney.edu.au/agriculture/pal/software/fuzme.shtml) software is more stable and efficient. I would recommend using that for most things. If you are trying to embed the classification into your R workflow though, the R packages is OK, but not as computationally efficient. I am working on it when i can.

### Useful Links

* [Source code](https://bitbucket.org/brendo1001/fuzme).

* A continuum approach to soil classification by modified [fuzzy k-means with extragrades](http://onlinelibrary.wiley.com/doi/10.1111/j.1365-2389.1992.tb00127.x/abstract)

<a href="#top">Back to top</a>

## Dissever <a id="s-5"></a>
-----

Dissever is a algorithm that was designed to facilitate a generalized method for downscaling coarsely resolved earth resource information using available finely gridded covariate data. Under the assumption that the relationship between the target variable being downscaled and the available covariates can be nonlinear, the original implementation of dissever used weighted generalized additive models (GAMs) to drive the empirical function. An iterative algorithm of GAM fitting and adjustment attempts to optimize the downscaling to ensure that the target variable value given for each coarse grid cell equals the average of all target variable values at the fine scale in each coarse grid cell. Dissever is described with more detail in [our paper]({{site.url }}/downloads/journal/malone2012_1.pdf) we did in 2011-12. 

Working with Landcare Research, in particular with Pierre Roudier, dissever was generalized so that alternative models other than GAMS could be used. The redesign of dissever was one outcome of collaborative research between the University of Sydney and Landcare Research. The Australian side of the project was funded by the Australian Government Department of Agriculture and Water Resources [Filling the Research Gap](http://www.agriculture.gov.au/ag-farm-food/climatechange/carbonfarmingfutures/ftrg) program. 


### Useful Links

[Source code](https://github.com/pierreroudier/dissever) was developed with the help of Pierre Roudier (Landcare Research New Zealand)

<a href="#top">Back to top</a>


## Tools for optimal sampling <a id="s-6"></a>
-----

Conditioned Latin hypercube sampling (cLHS) was proposed by [Minansy and McBratney (2006)](http://www.sciencedirect.com/science/article/pii/S009830040500292X). The aim of cLHS is to geographically locate samples (it was intended for soil sampling but can be applied to other sampling contexts too) such that the empirical distribution functions of the ancillary information associated with the samples are replicated, with a constraint that each k-tuple of ancillary information has to occur in the real world.

When using cLHS one often asks the question of how many samples should be collected? Other times, particularly when in the field and finding out that a sample location selected by cLHS can not be visited because of any number of reasons; they may ask, where else should i go then? Ideally in this situation the person would want to sample an alternative site that is very similar to the site (based on the multivariate information) that was unable to be visited. Another situation is when planning a new survey and one wants to use cLHS, but wants to be able to take into consideration prior or existing samples that have been collected from their sampling domain. Taking the existing samples into consideration may lessen the work required in conducting the new survey or better target areas that have been under-sampled.

I have developed a few workflows all developed in R, that answers those particular questions described above. The workflows exploit the use of the [clhs](https://cran.r-project.org/web/packages/clhs/index.html) R package developed by Pierre Roudier (Landcare Research New Zealand).


### Useful Links

[Source code](https://bitbucket.org/brendo1001/clhc_sampling). Each folder in the repo contain example scripts and data addressing the three questions detailed above. 

[Published paper](https://peerj.com/articles/5722/)

<a href="#top">Back to top</a>


## Tangles <a id="s-7"></a>

*Tangles* is an R package for anonymization of spatial point patterns and raster objects. This package achieves the relatively simple, yet pretty useful task of spatial anonymization. Anonymization is needed in situations where a data owner may not wish to share the actual spatial locations of their data, but allows sharing of the data that does not preclude the data from a spatial analysis procedure. Anonymization is achieved via 3 modes of spatial shifts:

* Vertical shifts
* Lateral shifts
* Rotational shifts

The tangles package can entangle both non-gridded spatial point patterns and raster objects. It can also entangle data using an a priory entanglement sequence, and can disentangle data back to their original spatial representations. Each entanglement process is given a unique hash key label to guarantee disentanglement is a success in terms of data being transformed back to their original representation.

### Useful Links
[Source code](https://github.com/brendo1001/tangles).

Installation of tangles can be achieved via Github using the devtools package:

``devtools::install_github("brendo1001/tangles")``

or via CRAN:

``install.packages("tangles")``

<a href="#top">Back to top</a>

