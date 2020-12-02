---
layout: page
title: Installing ithir
description: ""
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-05-24
---


## The `ithir` R package

The `ithir` `R` package is a necessary installation for being able to use the various `R` for digital soil mapping examples on this site. This is because it has all the required data sets and some of the required R functions. Some further information about `ithir` can be found [here]({{ site.url }}/software/#s-1/)

One you have installed a version of `R` onto your computer (see [part 1 of `R` literacy for digital soil mapping]({{ site.url }}/DSM_book/pages/r_literacy/part1/) page for instructions on how to do this if needed), you will need to use the following lines of `R` code:

```r
> install.packages("devtools") 
> library(devtools)
> install_bitbucket("brendo1001/ithir/pkg") #ithir package
```
An example script can also be downloaded from [here]({{ site.url }}/DSM_book/rcode/rPackageInstallation_ithir.R)