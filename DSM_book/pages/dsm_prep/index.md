---
layout: page
title: Preparatory and exploratory analysis for digital soil mapping
description: ""
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-06-18
---


In the [course fundamentals]({{ site.url }}/DSM_book/pages/introduction/), some of the history and theoretical underpinnings of DSM was discussed. Now with a solid foundation in `R`, it is time to put this all into practice i.e. do DSM with `R`.

-   [Soil depth functions]({{ site.url }}/DSM_book/pages/dsm_prep/splines/)
-   [Intersecting soil point observations with environmental covariates]({{ site.url }}/DSM_book/pages/dsm_prep/intersection/)
-   [Some exploratory soil data analyses]({{ site.url }}/DSM_book/pages/dsm_prep/processes/)

### What are you in for?

In the above pages some common methods for soil data preparation and exploration are covered. Soil point databases are inherently heterogeneous because soils are measured non uniformly from site to site. However one more-or-less commonality is that soil point observations will generally have some sort of label, together with some spatial coordinate information that indicates where the sample was collected from. Then things begin to vary from site to site. Probably the biggest difference is that all soils are not measured universally at the same depths. Some soils are sampled per horizon or at regular depths. Some soil studies examine only the topsoil, while others sample to the bedrock depth. Then different soil attributes are measured at some locations and depths, but not at others. Overall, it becomes quickly apparent when one begins working with soil data that a number of preprocessing steps are needed to fulfill the requirements of a particular analysis.

In order to prepare a collection of data for use in a DSM project as described in Minasny and McBratney (2010) one needs to examine what data are available, what is the soil attribute or class to be modeled? What is the support of the data? This includes whether observations represent soil point observations or some integral over a defined area (for now we just consider observations to be point observations). However, we may also assume the support to be also a function of depth in that we may be interested in only mapping soil for the top 10cm, or to 1m, or any depth in between or to the depth to bedrock. The depth interval could be a single value (such as one value for the 0-1m depth interval as an example), or we may wish to map simultaneously the depth variation of the target soil attribute with the lateral or spatial variation. These questions add complexity to the soil mapping project, but are an important consideration when planning a project and assessing what the objectives are.

More recent digital soil mapping research has examined the the combination of soil depths functions with spatial mapping in order to create soil maps with a near 3-D support. In the following section some approaches for doing this are discussed with emphasis and instruction on a particular method, namely the use of a mass-preserving soil depth function. This is followed by a page that will examine the important DSM step of linking observed soil information with available environmental covariates and the subsequent preparation of covariates for spatial modelling.

### References

Minasny, B, and A B McBratney. 2010. “Digital Soil Mapping: Bridging Research, Environmental Application, and Operation.” In, edited by J L Boettinger, D W Howell, A C Moore, A E Hartemink, and Kienast-Brown S, 429–25. Dordrecht: Springer.


