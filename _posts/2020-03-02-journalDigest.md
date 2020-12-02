---
layout: post
title: Journal Paper Digests
author: Brendan Malone
create: 2020-03-02
modified: 2020-03-02
image:
    feature: CachedImage.jpg
categories: [Research, Digests]
tags: [Journal Papers, Research]
---

## Journal Paper Digests 2020 #5

* Model parameterization to represent processes at unresolved scales and changing properties of evolving systems
* R software packages as a tool for evaluating soil physical and hydraulic properties
* Integrating satellite soil-moisture estimates and hydrological model products over Australia
*  Process-Guided Deep Learning Predictions of Lake Water Temperature






<!--more-->


###  Model parameterization to represent processes at unresolved scales and changing properties of evolving systems

By: Luo, Yiqi; Schuur, Edward A. G.

GLOBAL CHANGE BIOLOGY  Pages: NIL_1-NIL_9   Published: JAN 12 2020

Context Sensitive Links  Close Abstract

Modeling has become an indispensable tool for scientific research. However, models generate great uncertainty when they are used to predict or forecast ecosystem responses to global change. This uncertainty is partly due to parameterization, which is an essential procedure for model specification via defining parameter values for a model. The classic doctrine of parameterization is that a parameter is constant. However, it is commonly known from modeling practice that a model that is well calibrated for its parameters at one site may not simulate well at another site unless its parameters are tuned again. This common practice implies that parameter values have to vary with sites. Indeed, parameter values that are estimated using a statistically rigorous approach, that is, data assimilation, vary with time, space, and treatments in global change experiments. This paper illustrates that varying parameters is to account for both processes at unresolved scales and changing properties of evolving systems. A model, no matter how complex it is, could not represent all the processes of one system at resolved scales. Interactions of processes at unresolved scales with those at resolved scales should be reflected in model parameters. Meanwhile, it is pervasively observed that properties of ecosystems change over time, space, and environmental conditions. Parameters, which represent properties of a system under study, should change as well. Tuning has been practiced for many decades to change parameter values. Yet this activity, unfortunately, did not contribute to our knowledge on model parameterization at all. Data assimilation makes it possible to rigorously estimate parameter values and, consequently, offers an approach to understand which, how, how much, and why parameters vary. To fully understand those issues, extensive research is required. Nonetheless, it is clear that changes in parameter values lead to different model predictions even if the model structure is the same.

### 	 R software packages as a tool for evaluating soil physical and hydraulic properties

By: de Sousa, Dedola Fernandes; Rodrigues, Sueli; de Lima, Herdjania Veras; et al.

COMPUTERS AND ELECTRONICS IN AGRICULTURE  Volume: 168   Pages: 5077-5077   Published: JAN 2020

Context Sensitive Links Free Full Text from Publisher Close Abstract

The determination of soil physical properties requires complex analyzes performed by software, which are mostly paid access programs. The advantage of using R software is that it is open access and offers several packages for the analysis of soil physic-hydrical properties data. The objective of this review is to present and to disseminate the tools available in R for studies in soil physics. We briefly describe some packages of the R software for soil physics and analyze their ease of reproduction. From the examples given in the manuals of each package we observed that their reproducibility was not always self-explanatory, as verified for the packages soilwater and SoilHyP. The HydroMe and soilphysics packages were the most comprehensible to be reproduced. The most common determination offered by these packages is related to soil water retention curve models. We hope this will guide the soil science researchers to employ, more often, R codes to analyze their data. The R scripts that were used to exemplify the packages reported in this paper are available at https://github.com/sousaetal/COMPAG_2019_600.


### Integrating satellite soil-moisture estimates and hydrological model products over Australia

By: Khaki, M.; Zerihun, A.; Awange, J. L.; et al.

AUSTRALIAN JOURNAL OF EARTH SCIENCES  Volume: 67   Issue: 2   Pages: 265-277   Published: FEB 17 2020

Context Sensitive Links  Close Abstract

Accurate soil-moisture monitoring is essential for water-resource management and agricultural applications, and is now widely undertaken using satellite remote sensing or terrestrial hydrological models' products. While both methods have limitations, e.g. the limited soil depth resolution of space-borne data and data deficiencies in models, data-assimilation techniques can provide an alternative approach. Here, we use the recently developed data-driven Kalman-Takens approach to integrate satellite soil-moisture products with those of the Australian Water Resources Assessment system Landscape (AWRA-L) model. This is done to constrain the model's soil-moisture simulations over Australia with those observed from the Advanced Microwave Scanning Radiometer-Earth Observing System and Soil-Moisture and Ocean Salinity between 2002 and 2017. The main objective is to investigate the ability of the integration framework to improve AWRA-L simulations of soil moisture. The improved estimates are then used to investigate spatiotemporal soil-moisture variations. The results show that the proposed model-satellite data integration approach improves the continental soil-moisture estimates by increasing their correlation to independent in situ measurements (similar to 10% relative to the non-assimilation estimates).
HIGHLIGHTS
Satellite soil-moisture measurements are used to improve model simulation.
A data-driven approach based on Kalman-Takens is applied.
The applied data-integration approach improves soil-moisture estimates.


###  Process-Guided Deep Learning Predictions of Lake Water Temperature

By: Read, Jordan S.; Jia, Xiaowei; Willard, Jared; et al.

WATER RESOURCES RESEARCH  Pages: NIL_1-NIL_18   Published: NOV 16 2019

Context Sensitive Links Free Full Text from Publisher Close Abstract

The rapid growth of data in water resources has created new opportunities to accelerate knowledge discovery with the use of advanced deep learning tools. Hybrid models that integrate theory with state-of-the art empirical techniques have the potential to improve predictions while remaining true to physical laws. This paper evaluates the Process-Guided Deep Learning (PGDL) hybrid modeling framework with a use-case of predicting depth-specific lake water temperatures. The PGDL model has three primary components: a deep learning model with temporal awareness (long short-term memory recurrence), theory-based feedback (model penalties for violating conversation of energy), and model pretraining to initialize the network with synthetic data (water temperature predictions from a process-based model). In situ water temperatures were used to train the PGDL model, a deep learning (DL) model, and a process-based (PB) model. Model performance was evaluated in various conditions, including when training data were sparse and when predictions were made outside of the range in the training data set. The PGDL model performance (as measured by root-mean-square error (RMSE)) was superior to DL and PB for two detailed study lakes, but only when pretraining data included greater variability than the training period. The PGDL model also performed well when extended to 68 lakes, with a median RMSE of 1.65 degrees C during the test period (DL: 1.78 degrees C, PB: 2.03 degrees C; in a small number of lakes PB or DL models were more accurate). This case-study demonstrates that integrating scientific knowledge into deep learning tools shows promise for improving predictions of many important environmental variables.