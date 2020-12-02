---
layout: post
title: Journal Paper Digests
author: Brendan Malone
create: 2017-06-06
modified: 2017-06-06
image:
    feature: CachedImage.jpg
categories: [Research, Digests]
tags: [Journal Papers, Research]
---

## Journal Paper Digests 2017 #17

* Modification of the random forest algorithm to avoid statistical dependence problems when classifying remote sensing imagery
* Rule-based topology system for spatial databases to validate complex geographic datasets
* A pragmatic, automated approach for retroactive calibration of soil moisture sensors using a two-step, soil-specific correction




<!--more-->

### Modification of the random forest algorithm to avoid statistical dependence problems when classifying remote sensing imagery

Authors:
Canovas-Garcia, F; Alonso-Sarria, F; Gomariz-Castillo, F;
Onate-Valdivieso, F

Source:
*COMPUTERS & GEOSCIENCES*, 103 1-11; JUN 2017 

Abstract:
Random forest is a classification technique widely used in remote
sensing. One of its advantages is that it produces an estimation of
classification accuracy based on the so called out-of-bag
cross-validation method. It is usually assumed that such estimation is
not biased and may be used instead of validation based on an external
data-set or a cross-validation external to the algorithm.In this paper
we show that this is not necessarily the case when classifying remote
sensing imagery using training areas with several pixels or objects.
According to our results, out-of-bag cross-validation clearly
overestimates accuracy, both overall and per class. The reason is that,
in a training patch, pixels or objects are not independent (from a
statistical point of view) of each other; however, they are split by
bootstrapping into in bag and out-of-bag as if they were really
independent. We believe that putting whole patch, rather than
pixels/objects, in one or the other set would produce a less biased
out-of-bag cross-validation. To deal with the problem, we propose a
modification of the random forest algorithm to split training patches
instead of the pixels (or objects) that compose them. This modified
algorithm does not overestimate accuracy and has no lower predictive
capability than the original. When its results are validated with an
external data-set, the accuracy is not different from that obtained with
the original algorithm.We analysed three remote sensing images with
different classification approaches (pixel and object based); in the
three cases reported, the modification we propose produces a less biased
accuracy estimation.

### Rule-based topology system for spatial databases to validate complex geographic datasets

Authors:
Martinez-Llario, J; Coll, E; Nunez-Andres, M; Femenia-Ribera, C

Source:
*COMPUTERS & GEOSCIENCES*, 103 122-132; JUN 2017 

Abstract:
A rule-based topology software system providing a highly flexible and
fast procedure to enforce integrity in spatial relationships among
datasets is presented. This improved topology rule system is built over
the spatial extension Jaspa. Both projects are open source, freely
available software developed by the corresponding author of this
paper.Currently, there is no spatial DBMS that implements a rule-based
topology engine (considering that the topology rules are designed and
performed in the spatial backend). If the topology rules are applied in
the frontend (as in many GIS desktop programs), ArcGIS is the most
advanced solution. The system presented in this paper has several major
advantages over the ArcGIS approach: it can be extended with new
topology rules, it has a much wider set of rules, and it can mix feature
attributes with topology rules as filters. In addition, the topology
rule system can work with various DBMSs, including PostgreSQL, H2 or
Oracle, and the logic is performed in the spatial backend.The proposed
topology system allows users to check the complex spatial relationships
among features (from one or several spatial layers) that require some
complex cartographic datasets, such as the data specifications proposed
by INSPIRE in Europe and the Land Administration Domain Model (LADM) for
Cadastral data.

### A pragmatic, automated approach for retroactive calibration of soil moisture sensors using a two-step, soil-specific correction

Authors:
Gasch, CK; Brown, DJ; Brooks, ES; Yourek, M; Poggio, M; Cobos, DR;
Campbell, CS

Source:
*COMPUTERS AND ELECTRONICS IN AGRICULTURE*, 137 29-40; MAY 2017 

Abstract:
Soil moisture sensors are increasingly deployed in sensor networks for
both agronomic research and precision agriculture. Soil-specific
calibration improves the accuracy of soil water content sensors, but
laboratory calibration of individual sensors is not practical for
networks installed across heterogeneous settings. Using daily water
content readings collected from a sensor network (42 locations x 5
depths = 210 sensors) installed at the Cook Agronomy Farm (CAF) near
Pullman, Washington, we developed an automated calibration approach that
can be applied to individual sensors after installation. As a first
step, we converted sensor-based estimates of apparent dielectric
permittivity to volumetric water content using three different
calibration equations (Topp equation, CAF laboratory calibration, and
the complex refractive index model, or CRIM). In a second,
"re-calibration" step, we used two pedotransfer functions based upon
particle size fractions and/or bulk density to estimate water content at
wilting point, field capacity, and saturation at each sensor insertion
point. Using an automated routine, we extracted the same three reference
points, when present, from each sensor's record, and then bias corrected
and re-scaled the sensor data to match the estimated reference points.
Based on validation with field-collected cores, the Topp equation
provided the most accurate calibration with an RMSE of 0.074 m(3) m(-3),
but automated re-calibration with a local pedotransfer function
outperformed any of the calibrations alone, yielding a network-wide RMSE
of 0.055 m(3) m(-3). The initial calibration equation used in the first
step was irrelevant when the re-calibration was applied. After
correcting for the reference core measurement error of 0.026 m(3) m(-3)
used for calibration and validation, the error of the sensors alone
(RMSEadj) was computed as 0.049 m(3) m(-3). Sixty-five percent of
individual sensors exhibited re calibration errors less than or equal to
the network RMSEadj. The incorporation of soil physical information at
sensor installation sites, applied retroactively via an automated
routine to in situ soil water content sensors, substantially improved
network sensor accuracy. 



