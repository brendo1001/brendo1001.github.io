---
layout: page
title: Research Interests
description: "My research interests."
header-img: images/NZ2.jpg
comments: false
modified: 2016-11-17
---

My research specializations are pedometrics, chemometrics and digital soil mapping and assessment research. My main research objective is to seek out a definitive understanding of the spatial and temporal characteristics of soil so that we can be better custodians of them now and for generations to come. This driving motivation has seen me contribute significantly to the methodological development and delivery of comprehensive soil information systems. Most of my work basically seeks out new and innovative ways and inferences systems for soil measurement in all its dimensions, and designing systems that leverages soil and environmental data to facilitate nuanced decision making for optimal management of natural resources.  

## Pedometrics
-----
Pedometrics is a branch of soil science. The Pedometrics research community includes soil and environmental scientists, who are primarily interested in the use of statistical and mathematical tools to analyze and interpret soil data. I have been lucky enough to have worked alongside one of the key persons involved in the establishment of Pedometrics. It has been said that Prof. Alex McBratney coined the term. In any case the [history of Pedometrics](http://pedometrics.org/?page_id=7) is well documented and an interesting one. Importantly, Pedometrics is probably one of the most active soil science research communities. Pedometrics has a number of working groups that i engage with. These include: digital soil mapping, proximal soil sensing and digital soil morphometrics.  

### Useful Links

* [Pedometrics official site](http://pedometrics.org/)

* Pedometrics [Wikipedia](https://en.wikipedia.org/wiki/Pedometrics)

* [Pedometrics 2017](http://www.pedometrics2017.org/) in Wageningen, The Netherlands. 2017 is the 25 year anniversary of Pedometrics (being an established commission of the [IUSS](http://www.iuss.org/)).  


## Digital Soil Mapping
-----

Digital soil mapping (DSM) means the creation and population of spatial soil information systems by numerical models inferring the spatial and temporal variations of soil types and soil properties from soil observation and knowledge from related environmental variables [Lagacherie and McBratney 2006](http://www.sciencedirect.com/science/article/pii/S016624810631001X). The concepts and methodologies for DSM were formalized in a review by [McBratney et al. (2003)](http://www.sciencedirect.com/science/article/pii/S0016706103002234). In the McBratney et al. (2003) paper, the *scorpan* approach for predictive modelling (and mapping) of soil was introduced, which in itself is rooted in earlier works by [Jenny (1941)](https://books.google.com.au/books/about/Factors_of_soil_formation.html?id=h-dIAAAAMAAJ). *scorpan* is a mnemonic for factors for prediction of soil attributes: soil, climate, organisms, relief, parent materials, age, and spatial position. The scorpan approach is formulated by the equation:

$$
      S = f(s,c,o,r,p,a,n) + \epsilon\
$$


This equation states that the soil type or attribute at an unvisited site can be predicted from a numerical function or model (*f*) given the factors just described plus the locally varying, spatial dependent residuals $\epsilon$. The scorpan factors or environmental covariates come in the form of spatially populated digitally available data. For example from digital elevation models and the indices derived from them: slope, aspect, MRVBF etc. Landsat data, and other remote sensing images, radiometric data, geological survey maps, legacy soil maps and related data,just to name a few. 


### Topics

I think there are a number of interesting research topics that can be explored in DSM. It is an interesting exercise just learning how to create a digital map. There is something special about using real data, coupled with model-based methods and GIS that makes DSM so interesting and enlightening

* There are always new GIS tools becoming available that make DSM more efficient for researchers. This could be new software, interactive visualizations, online sharing mechanisms etc. DSM always needs to stay abreast of these developments.

* There are always new and improved sources of environmental data that could be of benefit to to DSM. 

* Proximal soil sesing technologies such as electromagnetic induction and gamma radiometrics are really useful for enhancing DSM, particularly for field and farm extents. New methods proximal sensing technologies need to be investigated, as are innovative and optimal ways of using them, for example at regional scales. 

* Methods of pre-processing soil data for DSM. Harmonizing soil profile data, detecting outliers, soil data visualizations, soil data summaries.

* Optimized sampling strategies that more efficient and less burdensome to implement.

* There are always new models being developed that could potentially be applicable for either continuous and categorical soil variables. There is particular interest in non-linear models or models that are not purely statistical models, but soil data models. The emphasis here is soil and not pure statistics.

* Methods for quantifying soil map uncertainty. We know that maps are not error free. We need innovative ways of making this important task more efficient.

* Methods for Assessing the quality of digital soil maps. How reliable are the maps we are making? How can we measure this?

* Methods for updating, harmonizing and disaggregating legacy soil mapping. 

* Methods for generating digital sol maps in situations of very sparse data.

* Methods for ensemble spatial modelling of soil attributes. 

* Methods for multiscale DSM. Can we resolve global or national extent mapping for field or farm applications? Is there a scale continuum for DSM? 

* Creating maps to the specifications of the end-user irrespective of the original data.



### Useful Links

Some of the topics listed above are considered in the [Using R for Digital Soil Mapping Book](http://www.springer.com/gp/book/9783319443256). This book provides an entry point to going about DSM. It is largely focused on the doing, rather than the theory and semantics. You will also learn how to go about things using the [R](https://cran.r-project.org/) scripting language too.

### Workshops

The Soil Security Laboratory at the University of Sydney offer courses and training materials in Digital soil mapping. Many of the topics described above are part of the curriculum. This course is delivered using free and open source tools. Make an email enquiry to find out more. 

## Digital Soil Assessment
-----

Digital soil assessment goes beyond the goals of digital soil mapping. Digital soil assessment (DSA) can be defined (from [McBratney et al. (2012)](http://www.crcnetbase.com/doi/abs/10.1201/b12728-4)) as the translation of digital soil mapping outputs into decision making aids that are framed by the particular contextual human-value system which addresses the question/s at hand. The concept of DSA was first framed by [Carre et al. (2007)](http://www.sciencedirect.com/science/article/pii/S0016706107002261) as a mechanism for assessing soil threats, assessing soil functions and for soil mechanistic simulations to assess risk based scenarios to complement policy development. Very simply DSA can be likened to the quantitative modeling of difficult-to-measure soil attributes and functions. An obvious candidate application for DSA is land suitability evaluation for a specified land use type. 

I have work on a collaborative research project with the Tasmanian Department of Primary Industries, Parks, Water and Environment specifically related to DSA. Here we were interested in making [digital assessments of enterprise suitability](http://dpipwe.tas.gov.au/agriculture/investing-in-irrigation/enterprise-suitability-toolkit) to support the expansion of irrigated agriculture across the state. This project has had a real impact and is a great example of significant scientific research underpinning Government policy. Such DSA projects enable soil scientists to collaborate with the wider scientific community, which i believe we should see more of.   


## Soil Spectral Inference
-----

Infrared diffuse reflectance spectroscopy is based on the principle that molecules have specific frequencies at which they rotate or vibrate corresponding to discrete energy levels. Absorption spectra of compounds are a unique reflection of their molecular structure. Spectroscopy in both the visible, near (Vis-NIR, 400-700-2500 nm) and mid (MIR, 2500-25,000 nm) infrared ranges allows rapid acquisition of soil information.

Spectral signatures of soil materials are characterized by their reflectance to particular wavelengths in the electromagnetic spectrum. Properties that are related to the surface area of the soil usually can be predicted well from Vis-NIR and MIR spectroscopy. Vis-NIR spectrometers are used extensively and gained popularity in soil science because they are available in a portable format, are easy and ready to use in the field and require minimal or even no sample preparation.
With proper calibration, they can be used to estimate many soil properties, namely total C, total N, sand and clay content, cation exchange capacity, and pH. Reviews on the principles and use of Vis-NIR for predicting soil properties can be found in [Stenberg et al. (2010)](http://www.sciencedirect.com/science/article/pii/S0065211310070057) and [Soriano-Disla et al. (2014)](http://www.tandfonline.com/doi/abs/10.1080/05704928.2013.811081). The application of infrared spectroscopy for detecting soil contaminants, particularly organic ones has also received much research attention.

Another popular soil spectral inference technique is X-ray Fluorescence (XRF). XRF offers rapid, real-time, simultaneous multi-elemental analysis of soil samples in a solid condition with minimal or no sample treatments. The growing availability of portable instrumentation has enabled new opportunities for performing soil analysis *in situ*.  

Portable XRF spectrometers operate on the principle of energy dispersive X-ray fluorescence spectrometry whereby the amount of emitted fluorescence photons is directly measured by an X-ray detector that simultaneously analyses their energy levels. The elemental composition of the soil sample is thus determined from the measured intensities of emitted fluorescence. Portable XRF is suitable for soil geochemical studies and assessments of soil weathering rates and indices. The technology is popularly used for soil contaminant detection, particularly heavy metals such as lead, arsenic, cadmium etc. 


### Topics

* Field spectroscopy for the assessment of [soil contaminants]({{ site.url }}/downloads/journal/malone2015_5.pdf)

* [Digital Soil Morphometrics](http://digitalsoilmorphometrics.org/). This is more-or-less the use of *in situ* soil sensing instrumentation to enhance pedological assessment and quantification of soil. Soil sensing instruments being the soil surveyors toolbox of the 21st Century.  


* Spectroscopic assessment of pedogenisis and [soil weathering indices](http://www.sciencedirect.com/science/article/pii/S0341816216300078)


### Useful Links

[Portable X-ray Fluorescence Spectrometry Analysis of Soils](https://dl.sciencesocieties.org/publications/msa/abstracts/1/1/methods-soil.2015.0033)

### Workshops

The Soil Security Laboratory at the University of Sydney offer courses and training materials in the spectroscopic analysis of soils. Topics covered include:

* Principles of NIR spectroscopy
* Sample preparation
* Data import and preparation
* Data pre-processing: smoothing, de-trending, removing baseline, continuum removal
* Filtering: Savitzky-Golay, wavelets
* Data visualisation
* Principal component analysis, biplots
* Calibration process: PLS, Cubist
* Identifying domains of prediction and outliers
* Detecting clay mineral suites
* Soil spectral inference
* Making it work in the field
* Removing the effects of moisture, etc. using External Parameter Orthogonalisation (EPO)
* Building & using a Soil Spectral Library

This course is delivered using free and open source tools. Make an email enquiry to find out more. 


## Digital Agriculture
-----

When i think about it, it is difficult to pin point exactly what digital agriculture is. When people talk about it, they often do so in terms of precision agriculture. Precision agriculture is the management of spatial variation for optimal farm productivity together with optimal application of inputs i.e. variable rate technology. People have been talking about precision agriculture since at least the early 1990s when the appropriate technology became available which was aided by widespread use of GPS systems. That is a small digression, but precision agriculture is essentially data driven decision making. This is opposed to agricultural management based on historical behavior and uniformly managed systems. So data driven decision making is a good working definition of digital agriculture too. The main thing here is that it applies to all facets of the agricultural supply chain from plant breeding right through to transportation logistics. Information technology is providing enabling ability to track, monitor, assess, and audit all processes and outputs along the entire supply chain. Sensing technology is making things efficient to measure and quantify. The ability to generate seemingly endless data streams is astounding. 

Subsequently, a research objective of digital agriculture is to distill the information that is being generated, and leverage new and useful knowledge from it. By benefiting from the enabling technology, we expect better decision making and management throughout the agricultural supply chain. The goal here is to improve efficiency, reduce costs, improve productivity, and improve the natural environment in which the commodities are produced. When we hear of a declining agricultural workforce, i tend to agree, but believe digital technologies may be able to fill some of the void through such mechanisms as automation. Nevertheless, I expect major shifts in the agriculture sector in the coming 10 to 20 years. Lets embrace the digital age. 


