---
layout: page
title: Soil Spatial Prediction Functions
description: "Continuous Variables"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-08-23    
---


## Regression kriging


In the previous pages we looked at a few soil spatial prediction
functions which at the most fundamental level, target the the
correlation between the target soil variable and the available covariate
information. We fitted a number of models which included simple linear
functions to non-linear functions such as regression trees to other more
complicated data mining techniques e.g. [Cubist]({{site.url}}/DSM_book/pages/dsm_cont/sspfs/cubist/) and [Random Forest]({{site.url}}/DSM_book/pages/dsm_cont/sspfs/rf/)).

In this section we will extend upon this DSM approach from what are
called deterministic models to also include the spatially correlated
residuals that result from fitting these models.

The approach we will now concentrate is a hybrid approach to modelling,
whereby the predictions of the target variable are made via a
deterministic method (regression model with covariate information) and a
stochastic method where we determine the spatial auto-correlation of the
model residuals with a variogram. The deterministic model essentially
*detrends* the data, leaving behind the residuals for which we need to
investigate whether there is additional spatial structure which could be
added to the regression model predictions. These residuals are the
random component of the $scorpan + e $ model. This method is described
as regression kriging and has formally been described in Odeh,
McBratney, and Chittleborough (1995) and is synonymous with universal
kriging (Hengl, Heuvelink, and Rossiter 2007), which is the formal
linear model procedure to this soil spatial modeling approach. The
purpose of this exercise is to introduce some basic concepts of
regression kriging. You will have already had some experience in
regression models. We have also investigated briefly the [fundamental concepts of kriging]({{site.url}}/DSM_book/pages/dsm_prep/processes/)
for which the variogram is central to.

-   [Universal Kriging]({{site.url}}/DSM_book/pages/dsm_cont/sspfs/RK/UK/)
-   [Hybrid regression kriging]({{site.url}}/DSM_book/pages/dsm_cont/sspfs/RK/UKH/)

### References

Hengl, T, G. B. M Heuvelink, and D. G Rossiter. 2007. “About Regression
Kriging: From Equations to Case Studies.” *Computers & Geosciences* 33:
1301–15.

Odeh, I. O. A, A. B McBratney, and D. J Chittleborough. 1995. “Further
Results on Prediction of Soil Properties from Terrain Attributes:
Heterotopic Co-Kriging and Regression Kriging.” *Geoderma* 67: 215–26.