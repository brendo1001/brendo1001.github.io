---
layout: post
title: Journal Paper Digests
author: Brendan Malone
create: 2020-10-19
modified: 2020-10-19
image:
    feature: CachedImage.jpg
categories: [Research, Digests]
tags: [Journal Papers, Research]
---

## Journal Paper Digests 2020 #16

* Molecular trade-offs in soil organic carbon composition at continental scale
* Linear mixed effects models for non‐Gaussian continuous repeated measurement data
* Circular regression trees and forests with an application to probabilistic wind direction forecasting
* Use of diffuse reflectance spectroscopy and Nix pro color sensor in combination for rapid prediction of soil organic carbon
* A framework for modelling soil structure dynamics induced by biological activity








<!--more-->

###  Molecular trade-offs in soil organic carbon composition at continental scale

https://www.nature.com/articles/s41561-020-0634-x

The molecular composition of soil organic carbon remains contentious. Microbial-, plant- and fire-derived compounds may each contribute, but whether they vary predictably among ecosystems remains unclear. Here we present carbon functional groups and molecules from a diverse spectrum of North American surface mineral soils, collected primarily from the National Ecological Observatory Network and quantified by nuclear magnetic resonance spectroscopy and a molecular mixing model. We find that soils vary widely in relative contributions of carbohydrate, lipid, protein, lignin and char-like carbon, but each compound class has similar overall abundance. Ninety percent of the variance in carbon composition can be explained by three principal component axes representing a trade-off between lignin and protein, a trade-off between carbohydrate and char, and lipids. Reactive aluminium, crystalline iron oxides and pH plus overlying organic horizon thickness—predictors that are all related to climate—best explain variation along each respective axis. Together, our data point to continental-scale trade-offs in soil carbon molecular composition that are linked to environmental and geochemical variables known to predict carbon mass concentrations. Controversies regarding the genesis of soil carbon and its potential responses to global change can be partially reconciled by considering diverse ecosystem properties that drive complementary persistence mechanisms.

### Linear mixed effects models for non‐Gaussian continuous repeated measurement data

Has an R package

https://rss.onlinelibrary.wiley.com/doi/10.1111/rssc.12405

We consider the analysis of continuous repeated measurement outcomes that are collected longitudinally. A standard framework for analysing data of this kind is a linear Gaussian mixed effects model within which the outcome variable can be decomposed into fixed effects, time invariant and time‐varying random effects, and measurement noise. We develop methodology that, for the first time, allows any combination of these stochastic components to be non‐Gaussian, using multivariate normal variance–mean mixtures. To meet the computational challenges that are presented by large data sets, i.e. in the current context, data sets with many subjects and/or many repeated measurements per subject, we propose a novel implementation of maximum likelihood estimation using a computationally efficient subsampling‐based stochastic gradient algorithm. We obtain standard error estimates by inverting the observed Fisher information matrix and obtain the predictive distributions for the random effects in both filtering (conditioning on past and current data) and smoothing (conditioning on all data) contexts. To implement these procedures, we introduce an R package: ngme. We reanalyse two data sets, from cystic fibrosis and nephrology research, that were previously analysed by using Gaussian linear mixed effects models.

### Circular regression trees and forests with an application to probabilistic wind direction forecasting

Has an R package 

https://rss.onlinelibrary.wiley.com/doi/10.1111/rssc.12437

Although circular data occur in a wide range of scientific fields, the methodology for distributional modelling and probabilistic forecasting of circular response variables is quite limited. Most of the existing methods are built on generalized linear and additive models, which are often challenging to optimize and interpret. Specifically, capturing abrupt changes or interactions is not straightforward but often relevant, e.g. for modelling wind directions subject to different wind regimes. Additionally, automatic covariate selection is desirable when many predictor variables are available, as is often the case in weather forecasting. To address these challenges we suggest a general distributional approach using regression trees and random forests to obtain probabilistic forecasts for circular responses. Using trees simplifies model estimation as covariates are used only for partitioning the data and subsequently just a simple von Mises distribution is fitted in the resulting subgroups. Circular regression trees are straightforward to interpret, can capture non‐linear effects and interactions, and automatically select covariates affecting location and/or scale in the von Mises distribution. Circular random forests regularize and smooth the effects from an ensemble of trees. The new methods are applied to probabilistic wind direction forecasting at two Austrian airports, considering other common approaches as a benchmark.

### Use of diffuse reflectance spectroscopy and Nix pro color sensor in combination for rapid prediction of soil organic carbon

Contemporary soil characterization is increasingly dependent upon proximal sensor data whereby high sample throughput and low-cost analysis are realized. Recent research studies have shown that combined sensor platforms generally offer greater predictive model stability and increased accuracy than the use of sensors in isolation. In this study, data from an inexpensive ($350 USD) Nix Pro color sensor, which measures the true color of an object by using red, blue, and green filters, was used with diffuse reflectance spectroscopy (DRS) (590–2490 nm) to predict soil organic carbon (OC) content in highly disturbed, landfill soils of India ex-situ. Generalized additive model (GAM) and partial least squares regression (PLSR) were applied to model DRS and Nix Pro data, respectively, both independently and by combining model predictions using a bilinear regression. Results showed that the combined model outperformed either sensor independently where the 30% external test set achieved a validation R2 of 0.95, residual prediction deviation (RPD) of 4.54, and the ratio of performance to interquartile range of 6.25 relative to laboratory-measured OC data. In contrary, the GAM-OC model using Nix Pro data alone and the PLSR-OC model using DRS data alone exhibited validation R2 values of 0.58 and 0.81, respectively. In sum, the addition of the inexpensive Nix Pro sensor substantively improved the prediction of soil OC relative to the use of DRS in isolation. Future studies should evaluate the effectiveness of such an approach on a wider variety of soil types (e.g., colors), its effectiveness in-situ under variable moisture conditions, and in possible combination with other proximal sensing platforms.

### A framework for modelling soil structure dynamics induced by biological activity

Soil degradation is a worsening global phenomenon driven by socio‐economic pressures, poor land management practices and climate change. A deterioration of soil structure at timescales ranging from seconds to centuries is implicated in most forms of soil degradation including the depletion of nutrients and organic matter, erosion and compaction. New soil–crop models that could account for soil structure dynamics at decadal to centennial timescales would provide insights into the relative importance of the various underlying physical (e.g. tillage, traffic compaction, swell/shrink and freeze/thaw) and biological (e.g. plant root growth, soil microbial and faunal activity) mechanisms, their impacts on soil hydrological processes and plant growth, as well as the relevant timescales of soil degradation and recovery. However, the development of such a model remains a challenge due to the enormous complexity of the interactions in the soil–plant system. In this paper, we focus on the impacts of biological processes on soil structure dynamics, especially the growth of plant roots and the activity of soil fauna and microorganisms. We first define what we mean by soil structure and then review current understanding of how these biological agents impact soil structure. We then develop a new framework for modelling soil structure dynamics, which is designed to be compatible with soil–crop models that operate at the soil profile scale and for long temporal scales (i.e. decades, centuries). We illustrate the modelling concept with a case study on the role of root growth and earthworm bioturbation in restoring the structure of a severely compacted soil.