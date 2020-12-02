---
layout: page
title: Data modelling with categorical type target variables
description: ""
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-07-26
---

In the [course fundamentals]({{ site.url }}/DSM_book/pages/introduction/), some of the history and theoretical underpinnings of DSM was discussed. Now with a solid foundation in `R`, it is time to put this all into practice i.e. do DSM with `R`. In the [DSM preparation]({{ site.url }}/DSM_book/pages/dsm_prep/) pages you were introduced to common steps need to get data in a format ready for spatial modelling. In a related effort you may have already covered sections on [data modelling with continous type target variables]({{ site.url }}/DSM_book/pages/dsm_cont/).

The other form of soil spatial prediction functions are those dealing with categorical target variables such as soil classes. Naturally the models we will use further on are not specific to soil classes but can be generally applied to any type of categorical data too.

In the examples to follow we will demonstrate the prediction of soil-landscape classes termed: Terrons. Terron relates to a soil and landscape concept that has an associated model. The concept was first described by Carre and McBratney (2005). The embodiment of Terron is a continuous soil-landscape unit or class which combines soil knowledge, landscape information, and their interactions together. Malone et al. (2014) detailed an approach for defining Terrons in the Lower Hunter Valley, NSW, Australia. This area is a prominent wine-growing region of Australia, and the development of Terrons is a first step in the realization of viticultural terroir — an established concept of identity that incorporates much more than just soil and landscape qualities (Vaudour et al. 2015).

In the work by Malone et al. (2014) they defined 12 Terrons for the Hunter Valley, which are distinguished by such soil and landscape characteristics as: geomorphometric attributes (derived from a digital elevation model) and specific attributes pertaining to soil pH, clay percentage, soil mineralogy (clay types and presence of iron oxides), continuous soil classes, and presence or absence of marl. The brief in the following examples is to predict the Terron classes across the prescribed Lower Hunter Valley, given a set of observations (sampled directly from the Terron map produced by Malone et al. (2014)).

By now you will be familiar with the process of [fitting models]({{ site.url }}/DSM_book/pages/dsm_cont/sspfs/) and [plotting/mapping the outputs]({{ site.url }}/DSM_book/pages/dsm_cont/prediction/). Thus in many ways, categorical datamodeling is similar (in terms of implementation) with prediction models of continuous variables. The example [demonstrating the use of the `caret` package]({{site.url }}/DSM_book/pages/dsm_cont/sspfs/caret/) can also be similarly applied for categorical variables too, where you will find many model functions suited to that type of data with that package.

In this section of pages we will have a look at a few different classification models:

-   [Multinomial logistic regression]({{ site.url }}/DSM_book/pages/dsm_cat/mlr/)
-   [Data mining with the C5 algorithm]({{ site.url }}/DSM_book/pages/dsm_cat/c5/)
-   [Random Forest]({{ site.url }}/DSM_book/pages/dsm_cat/rf/)

Key differences between modelling of continuous and categorical variables are the nature of validation and the estimation and expression of prediction uncertainty. It is probably worthwhile to spend some time if not already familiar with the common metrics for assessing the goodness of fit for categorical models. In the pages above some ways of expressing uncertainty of categorical models is also investigated.

-   [Model validation of categorical prediction models]({{ site.url }}/DSM_book/pages/dsm_cat/val/)

### References

Carre, F, and A B McBratney. 2005. “Digital Terron Mapping.” *Geoderma*
128: 340–53.

Malone, B P, P Hughes, A B McBratney, and B Minsany. 2014. “A Model for
the Identification of Terrons in the Lower Hunter Valley, Australia.”
*Geoderma Regional* 1: 31–47.

Vaudour, E, E Costantini, G V Jones, and S Mocali. 2015. “An Overview of
the Recent Approaches to Terroir Functional Modelling, Footprinting and
Zoning.” *SOIL* 1: 287–312.