---
layout: page
title: Software
description: "Software"
header-img: images/NZ1.jpg
comments: false
modified: 2016-11-16
---

Scientific software development plays a very important role in my research. Along with my research, I have developed some computing software to carry out the actual task. The software are coded mostly in R.

## ithir
-----

ithir is an R package that was initiated with the objective of providing a home to a suite of functions that would be of use to soil scientists and pedometricians. In its current version, it contains a few useful functions, but is more  a home to a variety of soil and related soil information data sets that are used in the [Using R for Digital Soil Mapping](http://www.springer.com/gp/book/9783319443256) book. Consequently, the package is now more-or-less a companion to that book if you want to complete the many examples that are contained therein. 

### Features


* Lots of varied soil and related soil information data sets. Different types of soil variable data. Different file formats: data frames, rasters etc.

* A couple of useful functions. Namely the equal-area smoothing spline (ea_spline) that is described in [Bishop et al. (1999)](http://www.sciencedirect.com/science/article/pii/S0016706199000038) and implemented within a digital soil maping context in [Malone et al. 2009]({{ site.url }}/downloads/journal/malone2009_2.pdf). This function is useful for harmonizing soil profile data and lets you return values from the observed data at standardized depth intervals. 

* There are a couple of little specialized plotting functions that helps you plot useful outputs from the spline fitting function. These are very basic and a bit buggy (Need to generalist these functions a bit more).


* Functions for goodness of fit statistics for both continuous (goof) and categorical data (goofcat)

* Clear documentation and examples about how to use each of the datasets and functions are automatically provided once the package is installed. 

### Useful Links

* [ithir source code](https://bitbucket.org/brendo1001/ithir/). This respository will also give instructions on how to install this package into your R environment. 



## DSMART
-----

DSMART means: Disaggregation and Harmonisation of Soil Map Units Through Resampled Classification Trees. [Odgers et al. (2014)](http://www.sciencedirect.com/science/article/pii/S0016706113003522)  provide a detailed explanation of the DSMART algorithm. The aim of DSMART is to predict the spatial distribution of soil classes by disaggregating the soil map units of a soil polygon map. Here soil map units are soil map are entities consisting of a deﬁned set of soil classes which occur together in a certain spatial pattern and in an assumed set of proportions. The DSMART method of representing the disaggregated soil class distribution is as a set of numerical raster surfaces, with one raster per soil class. The data representation for each soil class is given as the probability of occurrence. In order to generate the probability surfaces, a re-sampling approach is used to generate *n* realizations of the potential soil class distribution within each map unit. Then at each grid cell, the probability of occurrence of each soil class is estimated by the proportion of times the grid cell is predicted as each soil class across the set of realizations. The procedure of the DSMART algorithm can be summarized in 6 main steps:

1. Draw *n* random samples from each soil map polygon. 
2. Assign soil class to each sampling point.
    * Weighted random allocation from soil classes in relevant map unit
    * Relative proportions of soil classes within map units are used as the weights
3. Use sampling points and intersected covariate values to build a decision tree toprediction spatial distribution of soil classes.
4. Apply decision tree across mapping extent using covariate layers.
5. Steps 1–4 repeated *i* times to produce *i* realizations of soil class distribution. 
6. Using *i* realizations generate probability surfaces for each soil class.

The DSMART algorithm has been coded in C++ originally by Sun Wei (China), and then by Nathan Odgers (Australia) in Python who has also done some things with it in R as well. It is now available as a stand alone R package, where the DSMART algorithm is implemented in 2 steps or functions. The first function (dsmart) does the classification tree stuff and associated soil class prediction. The dsmartr function generates the probability rasters by aggregating outputs from the dsmart function. 

### Useful Links

* [dsmart source code](https://bitbucket.org/brendo1001/dsmart/). This respository will also give instructions on how to install this package into your R environment. Once installed the documentation and provided examples will help you get the algorithm running and understanding of the required inputs. 


## ospats
-----

text to fill

## fuzme
-----

text to fill

## dissever
-----

text to fill
