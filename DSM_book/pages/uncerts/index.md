---
layout: page
title: Quantification of Prediction Uncertainties
description: "For Digital Soil Mapping"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-09-20
---


## General Overview

Soil scientists are quite aware of the current issues concerning the
natural environment because our expertise is intimately aligned with
their understanding and alleviation. We know that sustainable soil
management alleviates soil degradation, improves soil quality and will
ultimately ensure food security. Critical to better soil management is
information detailing the soil resource, its processes and its variation
across landscapes. Consequently, under the broad umbrella of
environmental monitoring, there has been a growing need to acquire
quantitative soil information (McBratney, Mendonca Santos, and Minasny
2003; Grimm and Behrens 2010). The concerns of soil-related issues in
reference to environmental management were raised by McBratney (1992)
when stating that it is our duty as soil scientists, to ensure that the
information we provide to the users of soil information is both accurate
and precise, or at least of known accuracy and precision.

However, a difficulty we face is that soil can vary, seemingly
erratically in the context of space and time (Webster 2000). Thus the
conundrum in model-based predictions of soil phenomena is that models
are not error free. The unpredictability of soil variation combined with
simplistic representations of complex soil processes inevitably leads to
errors in model outputs.

We do not know the true character and processes of soils and our models
are merely abstractions of these real processes. We know this, or in
other words, in the absence of such confidence, we know we are uncertain
about the true properties and processes that characterize soils (Brown
and Heuvelink 2005). The key is therefore to determine to what extent
our uncertainties are propagated through a model of which effect the
final predictions of a real-world process.

In modeling exercises, uncertainty of the model output is the summation
of the three main sources which Minasny and McBratney (2002) and Brown
and Heuvelink (2005) describe as: - Model structure uncertainty - Model
parameter uncertainty, and - model input uncertainty

A detailed analysis of the contribution of each of the different sources
of uncertainty is generally recommended. In these pages we will cover a
few approaches to estimate the uncertainty of model outputs. Essentially
what this means is that given a defined level of confidence, model
predictions from digital soil mapping will be co-associated with the
requisite prediction interval or range. The approaches for quantifying
the prediction uncertainties are:

-   [Universal kriging prediction variance]({{ site.url }}/DSM_book/pages/uncerts/UKV/)
-   [Bootstrapping]({{ site.url }}/DSM_book/pages/uncerts/boot/)
-   [Empirical uncertainty quantification through data partitioning and cross validation]({{ site.url }}/DSM_book/pages/uncerts/partition/)
-   [Empirical uncertainty quantification through fuzzy clustering and cross validation]({{ site.url }}/DSM_book/pages/uncerts/fuzzy/)

The data that will be used in this chapter is a small data set of
subsoil pH that has been collected since 2001 to present from the Lower
Hunter Valley in New South Wales, Australia. The soil data covers an
area of approximately 220km**<sup>2</sup>. Validation of the
quantification of uncertainty will be performed using a subset of these
data. The mapping of the uncertainties will be conducted for a small
region of the study area. The data for this section can be retrieved
from the `ithir` package. The soil data is called `HV_subsoilpH` while
the grids of environmental covariates is called `hunterCovariates_sub`.

### References

Brown, J. D, and G. B. M Heuvelink. 2005. “Encyclopaedia of Hydrological
Sciences.” In, edited by M Anderson. John Wiley; Sons, Chichester.

Grimm, R, and T Behrens. 2010. “Uncertainty Analysis of Sample Locations
Within Digital Soil Mapping Approaches.” *Geoderma* 155: 154–63.

McBratney, A B. 1992. “On Variation, Uncertainty and Informatics in
Environmental Soil Management.” *Australian Journal of Soil Research*
30: 913–35.

McBratney, A B, M L Mendonca Santos, and B Minasny. 2003. “On Digital
Soil Mapping.” *Geoderma* 117: 3–52.

Minasny, B, and A. B McBratney. 2002. “Uncertainty Analysis for
Pedotransfer Functions.” *European Journal of Soil Science* 53: 417–29.

Webster, R. 2000. “Is Soil Variation Random?” *Geoderma* 97: 149–63.