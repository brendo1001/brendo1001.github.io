---
layout: page
title: Software
description: "Software"
header-img: images/NZ1.jpg
comments: false
modified: 2016-11-16
---

Scientific software development plays a very important role in my research. Along with my research, I have developed some computing software to carry out the actual task. The software are coded mostly in R

## ithir
-----

ithir is an R package that was initiated with the objective of providing a home to a suite of functions that would be of use to soil scientists and pedometricians. In its current version, it contains a few useful functions, but is more  a home to a variety of soil and related soil information datasets that are used in the [Using R for Digital Soil Mapping](http://www.springer.com/gp/book/9783319443256) book. Consequently, the packages is now more-or-less a companion to that book if you want to complete the many examples that are contained therein. 

### Features


* Lots of varied soil and related soil information datasets. Different types of soil variable data. Different file formats: data frames, rasters etc.

* A couple of useful functions. Namely the equal-area smoothing spline (ea_spline) that is described in [Bishop et al. (1999)](http://www.sciencedirect.com/science/article/pii/S0016706199000038) and implemented within a digital soil maping context in [Malone et al. 2009]({{ site.url }}/downloads/journal/malone2009_2.pdf). This function is useful for harmonising soil profile data and lets you return values from the observed data at standardised depth intervals. 

* There are a couple of little specialised plotting functions that helps you plot useful outputs from the spline fitting function. These are very basic and a bit buggy (Need to generalise these functions a bit more).


* Functions for goodness of fit statistics for both continuous (goof) and cateorical data (goofcat)

* Clear documentation and examples about how to use each of the datasets and functions is automatically provided once the package is installed. 

### Useful Links

* [ithir source code](https://bitbucket.org/brendo1001/ithir/). This respository will also give instructions on how to install this package into your R environment. 



## dsmart
-----

text to fill

## ospats
-----

text to fill

## fuzme
-----

text to fill

## dissever
-----

text to fill
