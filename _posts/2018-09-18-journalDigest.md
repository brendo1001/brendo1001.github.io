---
layout: post
title: Journal Paper Digests
author: Brendan Malone
create: 2018-09-18
modified: 2018-09-18
image:
    feature: CachedImage.jpg
categories: [Research, Digests]
tags: [Journal Papers, Research]
---

## Journal Paper Digests 2018 #17


* Sparse regression interaction models for spatial prediction of soil properties in 3D
* Enhanced IT2FCM algorithm using object-based triangular fuzzy set modeling for remote-sensing clustering
* Identification of geochemical anomalies through combined sequential Gaussian simulation and grid-based local singularity analysis
* Multi-scale segmentation algorithm for pattern-based partitioning of large categorical rasters
* Application of C-13 NMR Spectroscopy to the Study of Soil Organic Matter: A Review of Publications
* Predicting soil thickness on soil mantled hillslopes




<!--more-->

### Sparse regression interaction models for spatial prediction of soil properties in 3D

Authors:
Pejovic, M; Nikolic, M; Heuvelink, GBM; Hengl, T; Kilibarda, M; Bajat, B

Source:
*COMPUTERS & GEOSCIENCES*, 118 1-13; SEP 2018 

Abstract:
An approach for using lasso (Least Absolute Shrinkage and Selection
Operator) regression in creating sparse 3D models of soil properties for
spatial prediction at multiple depths is presented. Modeling soil
properties in 3D benefits from interactions of spatial predictors with
soil depth and its polynomial expansion, which yields a large number of
model variables (and corresponding model parameters). Lasso is able to
perform variable selection, hence reducing the number of model
parameters and making the model more easily interpretable. This also
prevents overfitting, which makes the model more accurate. The presented
approach was tested using four variable selection approaches - none,
stepwise, lasso and hierarchical lasso, on four kinds of models -
standard linear model, linear model with polynomial expansion of depth,
linear model with interactions of covariates with depth and linear model
with interactions of covariates with depth and its polynomial expansion.
This framework was used to predict Soil Organic Carbon (SOC) in three
contrasting study areas: Bor (Serbia), Edgeroi (Australia) and the
Netherlands. Results show that lasso yields substantial improvements in
accuracy over standard and stepwise regression - up to 50 % of total
variance. It yields models which contain up to five times less nonzero
parameters than the full models and that are usually more sparse than
models obtained by stepwise regression, up to three times. Extension of
the standard linear model by including interactions typically improves
the accuracy of models produced by lasso, but is detrimental to standard
and stepwise regression. Regarding computation time, it was demonstrated
that lasso is several orders of magnitude more efficient than stepwise
regression for models with tens or hundreds of variables (including
interactions). Proper model evaluation is emphasized. Considering the
fact that lasso requires meta-parameter tuning, standard
cross-validation does not suffice for adequate model evaluation, hence a
nested cross-validation was employed. The presented approach is
implemented as publicly available sparsereg3D R package.


### Enhanced IT2FCM algorithm using object-based triangular fuzzy set modeling for remote-sensing clustering

Authors:
Jiang, T; Hu, D; Yu, XC

Source:
*COMPUTERS & GEOSCIENCES*, 118 14-26; SEP 2018 

Abstract:
Object-based fuzzy clustering method has been widely used to
remote-sensing clustering analysis. Mean and interval spectral
signatures are typically used to describe an object's features. However,
accurately distinguishing two objects with the same mean or interval
values and different internal distributions is difficult. Focus on this
problem, we developed triangular fuzzy set modeling to describe objects
and designed an interval distance metric to measure the dissimilarities
between triangular fuzzy sets. Furthermore, using the variation of
fuzzifier (two fuzzifiers) to construct interval type-2 fuzzy c-means
(IT2FCM) clustering methods, which are sensitive to the choice of
fuzzifier, has uncertainty and subjectivity. Thus, an enhanced IT2FCM
clustering algorithm that directly adopts the interval distance metric
rather than the variation of fuzzifier is proposed for high-resolution
remote-sensing clustering. We performed land-cover classification
experiments for three study areas by utilizing remote-sensing images
from the SPOT-5 and Gaofen-2 satellite sensor, which spatial resolution
are approximately 10 m and 1 m, respectively. Visual and numerical
results, including Kappa coefficients and the confusion matrix, were
utilized to verify the classification results. The experimental results
indicated that triangular fuzzy set modeling is appropriate for
extracting features from ground objects; moreover, it limits the
classification errors caused by same objects with different spectral
features. Compared with the object-based interval-valued fuzzy c-means
(IV-FCM) method reported in the literature, the proposed algorithm
results in improved classification quality and accuracy.

### Identification of geochemical anomalies through combined sequential Gaussian simulation and grid-based local singularity analysis

Authors:
Wang, J; Zuo, RG

Source:
*COMPUTERS & GEOSCIENCES*, 118 52-64; SEP 2018 

Abstract:
Local singularity analysis (LSA) has been proven to be an effective tool
for identifying weak geochemical anomalies. The common practice of
grid-based LSA is to firstly interpolate irregularly distributed
observations onto a raster map by using either kriging or inverse
distance weighting (IDW). The inherent nature of the weighted moving
averaging of these methods typically subjects the interpolated map to a
smoothing effect. Additionally, the traditional procedure did not allow
for uncertainties on the values of geochemical attributes at unsampled
locations. As such, these two aspects might affect LSA results. This
paper presents a hybrid method, which combines sequential Gaussian
simulation and grid-based LSA to identify geochemical anomalies. A case
study of processing soil samples collected from the Jilinbaolige
district, Inner Mongolia, China, further illustrates the hybrid method
and helps compare the results with those from kriging-based LSA. The
findings indicate that (1) the uncertainties of values at unsampled
locations could affect the results of grid-based LSA, and (2)
singularity exponents from kriging-based LSA roughly represent the trend
(median) of singularity exponent distributions from simulation-based
LSA, but the latter can also provide a measure of uncertainty of
singularity exponent propagated from the uncertain values at unsampled
locations, and (3) the procedure combining simulation-based LSA and
analysis of distance is a feasible way for identifying geochemical
anomalies with uncertainty being considered. The anomaly probability map
obtained can provide a more generalized perspective than
interpolation-based LSA to delineate anomalous areas.

### Multi-scale segmentation algorithm for pattern-based partitioning of large categorical rasters

Authors:
Jasiewicz, J; Stepinski, T; Niesterowicz, J

Source:
*COMPUTERS & GEOSCIENCES*, 118 122-130; SEP 2018 

Abstract:
Analyzing large Earth Observation (EO) data on the broad spatial scales
frequently involves regionalization of patterns. To automate this
process we present a segmentation algorithm designed specifically to
delineate segments containing quasi-stationary patterns. The algorithm
is designed to work with patterns of a categorical variable. This makes
it possible to analyze very large spatial datasets (for example, a
global land cover) in their entirety. An input categorical raster is
first tessellated into small square tiles to form a new, coarser, grid
of tiles. A mosaic of categories within each tile forms a local pattern,
and the segmentation algorithm partitions the grid of tiles while
maintaining the cohesion of pattern in each segment. The algorithm is
based on the principle of seeded region growing (SRG) but it also
includes segment merging and other enhancements to segmentation quality.
Our key contribution is an extension of the concept of segmentation to
grids in which each cell has a non-negligible size and contains a
complex data structure (histograms of pattern features). Specific
modification of a standard SRG algorithm include: working in a distance
space with complex data objects, introducing six-connected "brick wall"
topology of the grid to decrease artifacts associated with tessellation
of geographical space, constructing the SRG priority queue of seeds on
the basis of local homogeneity of patterns, and using a
content-dependent value of segment-growing threshold. The detailed
description of the algorithm is given followed by an assessment of its
performance on test datasets representing three pertinent themes of land
cover, topography, and a high-resolution image. Pattern-based
segmentation algorithm will find application in ecology, forestry,
geomorphology, land management, and agriculture. The algorithm is
implemented as a module of GeoPAT - an already existing, open source
toolbox for performing pattern-based analysis of categorical rasters.

### Application of C-13 NMR Spectroscopy to the Study of Soil Organic Matter: A Review of Publications

Authors:
Chukov, SN; Lodygin, ED; Abakumov, EV

Source:
*EURASIAN SOIL SCIENCE*, 51 (8):889-900; AUG 2018 

Abstract:
Possibilities of NMR spectroscopy with C-13 nuclei application to the
study of soil organic matter and its various fractions is considered.
This is a non-destructive method, which is particularly valuable in the
analysis of various fractions of soil organic matter. It is regarded as
a direct method, and, unlike most of indirect methods, it allows one to
obtain reliable estimates of the ratio between virtually all groups of
carbon atoms in different organic molecules, including those in humus
specimens. Owing to impulse technique and high sensitivity, C-13-NMR
spectra may be obtained immediately from soil samples without any
extraction operations. The modern technique of obtaining spectra, their
mathematical processing (Fourier transform), and data interpretation are
considered. The results of applying C-13-NMR to the study of humus
substances, water-soluble fractions of soil organic matter, and soil
litters from different natural zones are discussed.

### Predicting soil thickness on soil mantled hillslopes

Authors:
Patton, NR; Lohse, KA; Godsey, SE; Crosby, BT; Seyfried, MS

Source:
*NATURE COMMUNICATIONS*, 9 3329-3329; AUG 20 2018 

Abstract:
Soil thickness is a fundamental variable in many earth science
disciplines due to its critical role in many hydrological and ecological
processes, but it is difficult to predict. Here we show a strong linear
relationship (r(2) = 0.87, RMSE = 0.19 m) between soil thickness and
hillslope curvature across both convergent and divergent parts of the
landscape at a field site in Idaho. We find similar linear relationships
across diverse landscapes (n = 6) with the slopes of these relationships
varying as a function of the standard deviation in catchment curvatures.
This soil thickness-curvature approach is significantly more efficient
and just as accurate as kriging-based methods, but requires only
high-resolution elevation data and as few as one soil profile.
Efficiently attained, spatially continuous soil thickness datasets
enable improved models for soil carbon, hydrology, weathering, and
landscape evolution.





