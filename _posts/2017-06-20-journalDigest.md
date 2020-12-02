---
layout: post
title: Journal Paper Digests
author: Brendan Malone
create: 2017-06-20
modified: 2017-06-20
image:
    feature: CachedImage.jpg
categories: [Research, Digests]
tags: [Journal Papers, Research]
---

## Journal Paper Digests 2017 #18

* A MATLAB based 3D modeling and inversion code for MT data
* Analysis of training sample selection strategies for regression-based quantitative landslide susceptibility mapping methods
* Extending R packages to support 64-bit compiled code: An illustration with spam64 and GIMMS NDVI3g data
* Spatio-ecological complexity measures in GRASS GIS
* Predicting the abundance of clays and quartz in oil sands using hyperspectral measurements
* Assessing gaps in irrigated agricultural productivity through satellite earth observations-A case study of the Fergana Valley, Central Asia
* Forecast of wheat yield throughout the agricultural season using optical and radar satellite images
* Rapid prediction of soil mineralogy using imaging spectroscopy
* Comparison of Soil Water Potential Sensors: A Drying Experiment
* [Essentials in Soil Physics: An introduction to Soil Processes, Functions, Structure and Mechanics](http://www.publish.csiro.au/book/7678/)
* Nonlinear parametric modelling to study how soil properties affect crop yields and NDVI
* [Honey authentication based on physicochemical parameters and phenolic compounds](http://www.sciencedirect.com/science/article/pii/S0168169916308614)
* Interoperable agro-meteorological observation and analysis platform for precision agriculture: A case study in citrus crop water requirement estimation
* An adaptive approach for UAV-based pesticide spraying in dynamic environments
* A comparison of SMOS and AMSR2 soil moisture using representative sites of the OzNet monitoring network












<!--more-->

### A MATLAB based 3D modeling and inversion code for MT data

Authors:
Singh, A; Dehiya, R; Gupta, PK; Israil, M

Source:
*COMPUTERS & GEOSCIENCES*, 104 1-11; JUL 2017 

Abstract:
The development of a MATLAB based computer code, AP3DMT, for modeling
and inversion of 3D Magnetotelluric (MT) data is presented. The code
comprises two independent components: grid generator code and
modeling/inversion code. The grid generator code performs model
discretization and acts as an interface by generating various I/O files.
The inversion code performs core computations in modular form forward
modeling, data functionals, sensitivity computations and regularization.
These modules can be readily extended to other similar inverse problems
like Controlled-Source EM (CSEM). The modular structure of the code
provides a framework useful for implementation of new applications and
inversion algorithms. The use of MATLAB and its libraries makes it more
compact and user friendly. The code has been validated on several
published models. To demonstrate its versatility and capabilities the
results of inversion for two complex models are presented.

### Analysis of training sample selection strategies for regression-based quantitative landslide susceptibility mapping methods

Authors:
Erener, A; Sivas, AA; Selcuk-Kestel, AS; Duzgun, HS

Source:
*COMPUTERS & GEOSCIENCES*, 104 62-74; JUL 2017 

Abstract:
All of the quantitative landslide susceptibility mapping (QLSM) methods
requires two basic data types, namely, landslide inventory and factors
that influence landslide occurrence (landslide influencing factors,
LIF). Depending on type of landslides, nature of triggers and LIF,
accuracy of the QLSM methods differs. Moreover, how to balance the
number of 0 (nonoccurrence) and 1 (occurrence) in the training set
obtained from the landslide inventory and how to select which one of the
1's and 0's to be included in QLSM models play critical role in the
accuracy of the QLSM. Although performance of various QLSM methods is
largely investigated in the literature, the challenge of training set
construction is not adequately investigated for the QLSM methods. In
order to tackle this challenge, in this study three different training
set selection strategies along with the original data set is used for
testing the performance of three different regression methods namely
Logistic Regression (LR), Bayesian Logistic Regression (BLR) and Fuzzy
Logistic Regression (FLR). The first sampling strategy is proportional
random sampling (PRS), which takes into account a weighted selection of
landslide occurrences in the sample set. The second method, namely
non-selective nearby sampling (NNS), includes randomly selected sites
and their surrounding neighboring points at certain preselected
distances to include the impact of clustering. Selective nearby sampling
(SNS) is the third method, which concentrates on the group of l's and
their surrounding neighborhood. A randomly selected group of landslide
sites and their neighborhood are considered in the analyses similar to
NNS parameters. It is found that LR-PRS, FLR-PRS and BLR-Whole Data
set-ups, with order, yield the best fits among the other alternatives.
The results indicate that in QLSM based on regression models, avoidance
of spatial correlation in the data set is critical for the model's
performance.

### Extending R packages to support 64-bit compiled code: An illustration with spam64 and GIMMS NDVI3g data

Authors:
Gerber, F; Mosinger, K; Furrer, R

Source:
*COMPUTERS & GEOSCIENCES*, 104 109-119; JUL 2017 

Abstract:
Software packages for spatial data often implement a hybrid approach of
interpreted and compiled programming languages. The compiled parts are
usually written in C, C++, or Fortran, and are efficient in terms of
computational speed and memory usage. Conversely, the interpreted part
serves as a convenient user interface and calls the compiled code for
computationally demanding operations. The price paid for the user
friendliness of the interpreted component is besides performance the
limited access to low level and optimized code. An example of such a
restriction is the 64-bit vector support of the widely used statistical
language R. On the R side, users do not need to change existing code and
may not even notice the extension. On the other hand, interfacing 64-bit
compiled code efficiently is challenging. Since many R packages for
spatial data could benefit from 64-bit vectors, we investigate
strategies to efficiently pass 64-bit vectors to compiled languages.
More precisely, we show how to simply extend existing R packages using
the foreign function interface to seamlessly support 64-bit vectors.
This extension is shown with the sparse matrix algebra R package spam.
The new capabilities are illustrated with an example of GIMMS NDVI3g
data featuring a parametric modeling approach for a non-stationary
covariance matrix.

### Spatio-ecological complexity measures in GRASS GIS

Authors:
Rocchini, D; Petras, V; Petrasova, A; Chemin, Y; Ricotta, C; Frigeri, A;
Landa, M; Marcantonio, M; Bastin, L; Metz, M; Delucchi, L; Neteler, M

Source:
*COMPUTERS & GEOSCIENCES*, 104 166-176; JUL 2017 

Abstract:
Good estimates of ecosystem complexity are essential for a number of
ecological tasks: from biodiversity estimation, to forest structure
variable retrieval, to feature extraction by edge detection and
generation of multifractal surface as neutral models for e.g. feature
change assessment. Hence, measuring ecological complexity over space
becomes crucial in macroecology and geography. Many geospatial tools
have been advocated in spatial ecology to estimate ecosystem complexity
and its changes over space and time. Among these tools, free and open
source options especially offer opportunities to guarantee the
robustness of algorithms and reproducibility. In this paper we will
summarize the most straightforward measures of spatial complexity
available in the Free and Open Source Software GRASS GIS, relating them
to key ecological patterns and processes.

### Predicting the abundance of clays and quartz in oil sands using hyperspectral measurements

Authors:
Entezari, I; Rivard, B; Geramian, M; Lipsett, MG

Source:
*INTERNATIONAL JOURNAL OF APPLIED EARTH OBSERVATION AND GEOINFORMATION*, 59 1-8; JUL 2017 

Abstract:
Clay minerals play a crucial role in the processability of oil sands
ores and in the management of tailings. An increase in fine content
generally leads to a decrease in both bitumen recovery performance and
tailings settling rate. It is thus important to identify clay types and
their abundance in oil sands ores and tailings. This study made use of
oil sands samples characterized for quantitative mineralogy by x-ray
diffraction, to gain an understanding of changes in the reflectance
spectra of oil sands. The sample suite included bitumen-removed oil
sands ore samples and their different fine size fractions. Spectral
metrics applicable to the prediction of quartz and clay contents in oil
sands were then derived with a focus on metrics correlating with sample
content in total 2:1 clays (total of illite and illite-smectite) and
kaolinite. Metrics in the shortwave infrared (SWIR) and longwave
infrared (LWIR) were found to correlate with mineral contents. The best
predictions of clays and quartz were achieved using LWIR metrics (R-2 >
0.89). Results also demonstrated the applicability of LWIR metrics in
the prediction of kaolinite and total 2:1 clays.

### Assessing gaps in irrigated agricultural productivity through satellite earth observations-A case study of the Fergana Valley, Central Asia

Authors:
Low, F; Biradar, C; Fliemann, E; Lamers, JPA; Conrad, C

Source:
*INTERNATIONAL JOURNAL OF APPLIED EARTH OBSERVATION AND GEOINFORMATION*, 59 118-134; JUL 2017 

Abstract:
Improving crop area and/or crop yields in agricultural regions is one of
the foremost scientific challenges for the next decades. This is
especially true in irrigated areas because sustainable intensification
of irrigated crop production is virtually the sole means to enhance food
supply and contribute to meeting food demands of a growing population.
Yet, irrigated crop production worldwide is suffering from soil
degradation and salinity, reduced soil fertility, and water scarcity
rendering the performance of irrigation schemes often below potential.
On the other hand, the scope for improving irrigated agricultural
productivity remains obscure also due to the lack of spatial data on
agricultural production (e.g. crop acreage and yield). To fill this gap,
satellite earth observations and a replicable methodology were used to
estimate crop yields at the field level for the period 2010/2014 in the
Fergana Valley, Central Asia, to understand the response of agricultural
productivity to factors related to the irrigation and drainage
infrastructure and environment. The results showed that cropping
pattern, i.e. the presence or absence of multi-annual crop rotations,
and spatial diversity of crops had the most persistent effects on crop
yields across observation years suggesting the need for introducing
sustainable cropping systems. On the other hand, areas with a lower crop
diversity or abundance of crop rotation tended to have lower crop
yields, with differences of partly more than one t/ha yield. It is
argued that factors related to the infrastructure, for example, the
distance of farms to the next settlement or the density of roads, had a
persistent effect on crop yield dynamics over time. The improvement
potential of cotton and wheat yields were estimated at 5%, compared to
crop yields of farms in the direct vicinity of settlements or roads. In
this study it is highlighted how remotely sensed estimates of crop
production in combination with geospatial technologies provide a unique
perspective that, when combined with field surveys, can support planners
to identify management priorities for improving regional production
and/or reducing environmental impacts.

### Forecast of wheat yield throughout the agricultural season using optical and radar satellite images

Authors:
Fieuzal, R; Baup, F

Source:
*INTERNATIONAL JOURNAL OF APPLIED EARTH OBSERVATION AND GEOINFORMATION*, 59 147-156; JUL 2017 

Abstract:
The aim of this study is to estimate the capabilities of forecasting the
yield of wheat using an artificial neural network combined with
multi-temporal satellite data acquired at high spatial resolution
throughout the agricultural season in the optical and/or microwave
domains. Reflectance (acquired by Formosat-2, and Spot 4-5 in the green,
red, and near infrared wavelength) and multi-configuration
backscattering coefficients (acquired by TerraSAR-X and Radarsat-2 in
the X- and C-bands, at co- (abbreviated HH and VV) and
cross-polarization states (abbreviated HV and VH)) constitute the input
variable of the artificial neural networks, which are trained and
validated on the successively acquired images, providing yield forecast
in near real-time conditions. The study is based on data collected over
32 fields of wheat distributed over a study area located in southwestern
France, near Toulouse. Among the tested sensor configurations, several
satellite data appear useful for the yield forecasting throughout the
agricultural season (showing coefficient of determination (R-2) larger
than 0.60 and a root mean square error (RMSE) lower than 9.1 quintals by
hectare (q ha(-1))): C-vH, C-Hv, or the combined used of X-HH and C-HH,
C-HH and C-Hv, or green reflectance and C-HH. Nevertheless, the best
accurate forecast (R-2 = 0.76 and RMSE= 7.0 q ha(-1)) is obtained
longtime before the harvest (on day 98, during the elongation of stems)
using the combination of co- and cross-polarized backscattering
coefficients acquired in the C-band (C-vv and C-vH). These results
highlight the high interest of using synthetic aperture radar (SAR) data
instead of optical ones to early forecast the yield before the harvest
of wheat. 

### Rapid prediction of soil mineralogy using imaging spectroscopy

Authors:
Omran, ESE

Source:
*EURASIAN SOIL SCIENCE*, 50 (5):597-612; MAY 2017 

Abstract:
Hyperspectral images provide rich spectral and spatially continuous
information that can be used for soil mineralogy discrimination. This
paper proposes a method to evaluate the feasibility of Hyperion image in
the rapid prediction of soil mineralogy. Four areas in Egypt were chosen
for the current study. Preprocessing of the Hyperion data was done
before applying the atmospheric correction. The minimum noise fraction
transformation was used to segregate noise in the data. Various
techniques were applied to the studied areas in which mixture tune
matched filtering gave good results in a prediction of the end-members.
Then, it employed to predict soil minerals in each cell using a spectral
unmixing method. Illite, chlorite, calcite, dolomite, kaolinite,
smectite, quartz, hematite, goethite, vermiculite, palygorskite and some
feldspar were identified. In addition, sand and limestone, calcite and
dolomite, and sand surface from similarly bright clouds can be
distinguished easily based on the proposed method. The soil minerals
obtained from X-ray diffraction analysis of the soil samples are in
conformity with spectrally dominant mineralogy from Hyperion data.
Different minerals can be identified using this method without any
knowledge of field spectra or any a priori field data, thus configuring
a "true" remote sensing method.


### Comparison of Soil Water Potential Sensors: A Drying Experiment

Authors:
Degre, A; van der Ploeg, MJ; Caldwell, T; Gooren, HPA

Source:
*VADOSE ZONE JOURNAL*, 16 (4):NIL_4-NIL_11; APR 2017 

Abstract:
The soil water retention curve (WRC) plays a major role in a soil's
hydrodynamic behavior. Many measurement techniques are currently
available for determining the WRC in the laboratory. Direct in situ WRC
can be obtained from simultaneous soil moisture and water potential
readings covering a wide tension range, from saturation to the wilting
point. There are many widely used soil moisture probes. Whereas
near-saturation tension can be measured using water-filled tensiometers,
wider ranges of water potential require new, more expensive, and less
widely used probes. We compared three types of soil water potential
sensors that could allow us to measure water potential in the field,
with a range relevant to water uptake by plants. Polymer tensiometers
(POTs), MPS-2 probes, and pF meters were compared in a controlled drying
experiment. The study showed that the POTs and MPS-2 probes had good
reliability in their respective ranges. Combined with a soil moisture
probe, these two sensors can provide observed WRCs. The pF meters below
-30 kPa were inaccurate, and their response was sensitive to measurement
interval, with greater estimated suction at shorter measurement
intervals. In situ WRC can provide supplementary information,
particularly with regard to its spatial and temporal variability. It
could also improve the results of other measurement techniques, such as
geophysical observations.

### Nonlinear parametric modelling to study how soil properties affect crop yields and NDVI

Authors:
Whetton, R; Zhao, YF; Shaddad, S; Mouazen, AM

Source:
*COMPUTERS AND ELECTRONICS IN AGRICULTURE*, 138 127-136; JUN 1 2017 

Abstract:
This paper explores the use of a novel nonlinear parametric modelling
technique based on a Volterra Non-linear Regressive with eXogenous
inputs (VNRX) method to quantify the individual, interaction and overall
contributions of six soil properties on crop yield and normalised
difference vegetation index (NDVI). The proposed technique has been
applied on high sampling resolution data of soil total nitrogen (TN) in
%, total carbon (TC) in %, potassium (K) in cmol kg(-1), pH, phosphorous
(P) in mg kg-I and moisture content (MC) in %, collected with an on-line
visible and near infrared (VIS-NIR) spectroscopy sensor from a 18 ha
field in Bedfordshire, UK over 2013 (wheat) and 2015 (spring barley)
cropping seasons. The online soil data were first subjected to a raster
analysis to produce a common 5 m by 5 m grid, before they were used as
inputs into the VNRX model, whereas crop yield and NDVI represented
system outputs. Results revealed that the largest contributions commonly
observed for both yield and NDVI were from K, P and TC. The highest sum
of the error reduction ratio (SERR) of 48.59% was calculated with the
VNRX model for NDVI, which was in line with the highest correlation
coefficient (r) of 0.71 found between measured and predicted NDVI.
However, on-line measured soil properties led to larger contributions to
early measured NDVI than to a late measurement in the growing season.
The performance of the VNRX model was better for NDVI than for yield,
which was attributed to the exclusion of the influence of crop diseases,
appearing at late growing stages. It was recommended to adopt the VNRX
method for quantifying the contribution of on-line collected soil
properties to crop NDVI and yield. However, it is important for future
work to include additional soil properties and to account for other
factors affecting crop growth and yield, to improve the performance of
the VNRX model.


### Honey authentication based on physicochemical parameters and phenolic compounds

Authors:
Oroian, M; Sorina, R

Source:
*COMPUTERS AND ELECTRONICS IN AGRICULTURE*, 138 148-156; JUN 1 2017 

Abstract:
The aim of this study is to assess the usefulness of physicochemical
parameters (pH, water activity, free acidity, refraction index, Brix,
moisture content and ash content), color parameters (L*, a*, b*, chroma,
hue angle and yellow index) and phenolics (quercetin, apigenin,
myricetin, isorhamnetin, kaempherol, caffeic acid, chrysin, galangin,
luteolin, p-coumaric acid, gallic acid and pinocembrin) in view of
classifying honeys according to their botanical origin (acacia, tilia,
sunflower, honeydew and polyfloral). Thus, the classification of honeys
has been made using the principal component analysis (PCA), linear
discriminant analysis (LDA) and artificial neural networks (ANN). The
multilayer perceptron network with 2 hidden layers classified correctly
94.8% of the cross validated samples.

### Interoperable agro-meteorological observation and analysis platform for precision agriculture: A case study in citrus crop water requirement estimation

Authors:
Sawant, S; Durbha, SS; Adinarayana, J

Source:
*COMPUTERS AND ELECTRONICS IN AGRICULTURE*, 138 175-187; JUN 1 2017 

Abstract:
Advances in Internet of Things (IoT) based sensing systems have improved
capabilities to precisely monitor environmental conditions. Plants are
sessile organisms and are affected by biotic and abiotic stresses caused
due to surrounding environmental conditions such as soil water content,
pest/disease infestation, and soil health. High-resolution sensing
(Wireless Sensor Networks (WSN) Systems) of agrometeorological
parameters helps to solve critical issues about the crop-weather-soil
continuum. Currently, many WSN systems are deployed all over the World
for precision agriculture purposes. Although there have been many
improvements in the communication aspects of the WSN's, the data
dissemination and near real-time analysis components for taking dynamic
decision, particularly in agriculture domain has not matured. The
current WSN systems do not have a standardized way of data discovery,
access, and sharing, which impedes the integration of data across
various distributed sensor networks. This study addresses above issues
through the adaptation of a framework based on Open Geospatial
Consortium (OGC) standards for Sensor Web Enablement (SWE). For
precision agriculture applications a cost-effective, standardized
sensing system (hardware and software) has been developed, which
includes functionalities such as sensors plug-n-play, remote monitoring,
tools for crop water requirement estimation, pest, disease monitoring,
and nutrient management. Also, the modeling techniques were integrated
with the interoperable web-enabled sensing system for addressing water
management problems of horticultural crops in semi-arid areas. 

### An adaptive approach for UAV-based pesticide spraying in dynamic environments

Authors:
Faical, BS; Freitas, H; Gomes, PH; Mano, LY; Pessin, G; de Carvalho,
ACPLF; Krishnamachari, B; Ueyama, J

Source:
*COMPUTERS AND ELECTRONICS IN AGRICULTURE*, 138 210-223; JUN 1 2017 

Abstract:
Agricultural production has become a key factor for the stability of the
world economy. The use of pesticides provides a more favorable
environment for the crops in agricultural production. However, the
uncontrolled and inappropriate use of pesticides affect the environment
by polluting preserved areas and damaging ecosystems. In the precision
agriculture literature, several authors have proposed solutions based on
Unmanned Aerial Vehicles (UAVs) and Wireless Sensor Networks (WSNs) for
developing spraying processes that are safer and more precise than the
use of manned agricultural aircraft. However, the static configuration
usually adopted in these proposals makes them inefficient in
environments with changing weather conditions (e.g. sudden changes of
wind speed and direction). To overcome this deficiency, this paper
proposes a computer-based system that is able to autonomously adapt the
UAV control rules, while keeping precise pesticide deposition on the
target fields. Different versions of the proposal, with autonomously
route adaptation metaheuristics based on Genetic Algorithms, Particle
Swarm Optimization, Simulated Annealing and Hill-Climbing for optimizing
the intensity of route changes are evaluated in this study.
Additionally, this study evaluates the use of a ground control station
and an embedded hardware to run the route adaptation metaheuristics.
Experimental results show that the proposed computer-based system
approach with autonomous route change metaheuristics provides more
precise changes in the UAV's flight route, with more accurate deposition
of the pesticide and less environmental damage. 

### A comparison of SMOS and AMSR2 soil moisture using representative sites of the OzNet monitoring network

Authors:
Yee, MS; Walker, JP; Rudiger, C; Parinussa, RM; Koike, T; Kerr, YH

Source:
*REMOTE SENSING OF ENVIRONMENT*, 195 297-312; JUN 15 2017 

Abstract:
This paper evaluates the performance of different soil moisture products
from AMSR2 and SMOS against the most representative stations within the
Yanco study area in the Murrumbidgee catchment, in southeast Australia.
AMSR2 Level 3 (L3) soil moisture products retrieved from two versions of
brightness temperatures using the Japanese Aerospace eXploration Agency
(JAXA) and the Land Parameter Retrieval Model (LPRM) algorithm were
included. For the LPRM algorithm, two different parameterization methods
were applied. Furthermore, two versions of SMOS L3 soil moisture product
were assessed. The results are contrasted against the use of "random"
stations. Accounting for all versions, frequencies and overpasses, the
latest versions of the JAXA UX2) and LPRM (LP3) products were found to
surpass the earlier versions (JX1, LP1 and LP2). Soil moisture retrieval
based on the latter version of brightness temperature and
parameterization scheme improved when C-band observations were used but
not X-band. However, X-band retrievals (r: 0.71, MAE: 0.07, RMSD: 0.08
m3/m3) were found to perform better than C-band (r: 0.68-0.70, MAE:
0.070.09 m(3)/m(3), RMSD: 0.09-0.10 m(3)/m(3)). Moreover, an
intercomparison between different acquisition times (morning and
evening) of AMSR2 X-band products found a better performance from
evening overpasses (1:30 pm; r: 0.69-0.77) as opposed to morning
overpasses (1:30 am; r: 0.47-0.66). In the case of SMOS, morning (6:00
am; r: 0.77) retrievals were found to be superior over evening (6:00 pm;
r: 0.69) retrievals. Overall, both versions of JAXA products, the second
and third versions of LPRM X-band products, and two versions of SMOS
products were found to meet the mean average error (MAE) goal accuracy
of the AMSR2 mission (MAE < 0.08 m(3)/m(3)) but none of the products
achieved the SMOS goal of RMSD < 0.04 m(3)/m(3). Furthermore,
performance of the products differed depending on the statistic used to
evaluate them. Consequently, considering the results in this study, JX2
products are recommended if both absolute and temporal accuracy of the
soil moisture product is of importance, whereas LP3(x) products from
evening observations and SMOS version 3.00 (SMOS2) products from morning
overpasses are recommended if temporal accuracy is of greater
importance. 












