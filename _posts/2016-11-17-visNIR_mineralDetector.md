---
layout: post
title: Vis-NIR soil mineral detection
author: Brendan Malone
create: 2016-11-17
modified: 2016-11-17
image:
    feature: images/beebop_home.jpg
categories: [Soil Science, Spectroscopy, R, Soil Minerals]
tags: [R, Markdown, Workshop, Soil]
---


<span style="color:brown">**Sydney Soil Schools**</span>
========================================================

### *Soil Spectral Inference Workshop*

### March 30 - April 1, 2016

Soil Material Identification from vis-NIR spectra
=================================================

**Copyright 2016, Soil Security Lab, The University of Sydney**

Introduction
------------

Clay minerals and iron oxides absorb at specific wavelengths in the
vis-NIR range of the electro-magnetic spectrum (Clark et al. 1990).
Previous studies have demonstrated the use of soil vis-NIR spectra in
soil compositional studies with notable success (Viscarra Rossel et al.
2009; Brown et al. 2006). The idea behind assessing the mineral
composition of soils with vis-NIR spectroscopy is to compare the
reflectance of the diagnostic wavelengths from some given reference
spectra with the reflectance at the same wavelengths of the soil
samples. The major diagnostic wavelengths for detecting some clay
minerals and iron oxides are summarised in the table below. A useful
repository of reference material with corresponding measured spectra is
the [U.S. Geological Survey digital spectral
library](http://speclab.cr.usgs.gov/spectral.lib06/ds231/datatable.html)
(Clark et al. 2007). For example, in this exercise the following
reference mineral spectra of the end member clay minerals and iron
oxides were retrieved from this repository: kaolinite (KGa-2), illite
(GDS4), smectite (SWy-1), kaolinite-smectite 50/50 mixture (H89-FR-2),
goethite (GDS240), and hematite (GDS576).

<table>
<caption>Some diagnostic vis-NIR wavelength ranges of some secondary clay minerals and iron oxides.</caption>
<thead>
<tr class="header">
<th align="left">Mineral</th>
<th align="left">Diagnostic wavelength ranges/s (nm)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Kaolin</td>
<td align="left">2078-2267</td>
</tr>
<tr class="even">
<td align="left">Smectite</td>
<td align="left">2118-2287</td>
</tr>
<tr class="odd">
<td align="left">Kaolin-smectite 50-50 mixture</td>
<td align="left">2128-2258</td>
</tr>
<tr class="even">
<td align="left">Illite</td>
<td align="left">2155-2266, 2306-2385</td>
</tr>
<tr class="odd">
<td align="left">Geothite</td>
<td align="left">457-563, 776-1266</td>
</tr>
<tr class="even">
<td align="left">Hematite</td>
<td align="left">455-612, 765-1050</td>
</tr>
</tbody>
</table>

To initiate the comparison between the reference material spectra and
soil spectra, first (for each of the reference and soil spectra), the
wavelength ranges specifically diagnostic to each clay mineral and iron
oxide specimen is isolated. Each range is then normalised separately by
fitting a convex hull to it, followed by computation of the deviation
from the fitted hull (Clark and Roush 1984). The same procedure is done
for the collected soil spectra. With the normalised spectra, the likely
presence of each clay mineral and iron oxide in each soil is estimated
when it is compared to that of the normalised reference spectra. The
approach for comparison that is about to be described is based on the
approach developed by the U.S. Geological Survey and implemented in
their Tetracorder decision making framework (Clark et al. 2003).
Fundamentally, Tetracorder uses a shape-fitting algorithm, which
essentially reduces down to a correlation between the reference spectra
and the observed soil spectra. The correlation coefficient of this fit
(*F*) is a quantitative estimate of the shape similarity between the
reference and soil spectra. Other criteria used for estimating
similarity to the reference spectra are the relative depth and relative
area of the soil spectral feature (to the reference). The slope of the
continuum is also used, particularly for the positive identification of
iron oxides. The depth of a spectral feature is calculated by:

$$

D= 1- \\frac{R\_{b}}{R\_{c}} 

$$

*D* is the depth of the spectral feature, and *R*<sub>*b*</sub> is the
reflectance value of the raw isolated spectra where the minimum
reflectance value of the continuum-removed spectra is observed.
*R*<sub>*c*</sub> is the minimum reflectance in the continuum-removed
feature. The relative depth is calculated as the ratio of the spectral
feature depth of a soil sample over that of the given reference spectra.
This is the same as for relative areas, where areas (of the spectral
features) are estimated by the conventional area calculation method. The
'relative abundance' of a clay mineral or iron oxide in a particular
soil sample can be derived by:

$$M\_{ab}= F \\times r\_{D}\\times r\_{A}\\tag{Equation 2}$$

where *M*<sub>*a**b*</sub> is the relative abundance of a given soil
mineral, *r*<sub>*D*</sub> is the relative depth of the spectral feature
for the diagnostic wavelength for a given reference mineral species and,
finally, *r*<sub>*A*</sub> is the relative spectral feature area. In the
case where there is more than one diagnostic spectral feature such as
for illite or both the iron oxide hematite and goethite,
*M*<sub>*a**b*</sub> is derived by:

$$M\_{ab}=\\sum\_{i=1}^n c\_{i}\\times F\_{i} \\times r\_{D\_{i}}\\times r\_{A\_{i}}\\tag{Equation 3}$$

where *n* is the number of diagnostic spectral features, and
*c*<sub>*i*</sub> is the proportional area of the reference spectral
feature *i* to the total summed area of the (reference mineral) spectral
features.

In this section we will:

1.  Using the one of the reference material spectra extracted from the
    USGS repository as an example, perform the continuum removal
    procedure within the specified diagnostic wavelengths.
2.  From the normalised reference material spectra, estimate a number of
    parameters (shape, area, depth, slope) that quantitatively describe
    the features of the spectra within the diagnostic wavelength range.
3.  Using some collected soil spectra, estimate the likely presence or
    relative abundance of clay minerals and iron oxides.

Reference material spectra
--------------------------

The [USGS spectral
library](http://speclab.cr.usgs.gov/spectral.lib06/ds231/datatable.html)
is a vast database of spectra together with sample descriptions of many
hundreds of samples and reference materials. We have extracted out and
post-processed a few of these spectra that correspond to the clay
minerals and iron oxides mentioned above. These are collectively
contained in the file **reference\_minerals.txt**. We will load this
file and assign it to the <tt>mineral\_ref</tt> object

    mineral_ref<- read.table("reference_minerals.txt",sep=",", header=T)
    str(mineral_ref)

    ## 'data.frame':    2151 obs. of  13 variables:
    ##  $ wavelength         : int  350 351 352 353 354 355 356 357 358 359 ...
    ##  $ Geothite           : num  0.0191 0.0191 0.0189 0.0187 0.0185 0.0183 0.0181 0.018 0.0179 0.0178 ...
    ##  $ hematite           : num  0.0199 0.019 0.0182 0.0176 0.0172 0.017 0.017 0.0171 0.0172 0.0174 ...
    ##  $ gypsum             : num  0.872 0.873 0.874 0.874 0.874 ...
    ##  $ calcite            : num  0.796 0.798 0.799 0.799 0.798 ...
    ##  $ kaolinite_114      : num  0.324 0.329 0.334 0.339 0.343 ...
    ##  $ kaolinite_113      : num  0.386 0.392 0.399 0.405 0.411 ...
    ##  $ montmorillinite_126: num  0.32 0.322 0.324 0.325 0.327 ...
    ##  $ monmorillinite_127 : num  0.502 0.504 0.505 0.507 0.508 ...
    ##  $ illite_121         : num  0.355 0.356 0.358 0.359 0.36 ...
    ##  $ illite_120         : num  0.154 0.154 0.153 0.153 0.153 ...
    ##  $ kaol_smect_124     : num  0.114 0.116 0.118 0.121 0.123 ...
    ##  $ kaol_smect_125     : num  0.136 0.138 0.14 0.142 0.144 ...

You will note that for some reference minerals there is more than one
spectrum. In fact, as you will note from the USGS spectral library,
there can be many tens of samples of the same reference material. They
may slightly differ in terms of where the sample was collected from, and
the grain size of the sample etc., which will in turn result in slightly
different absorbance features within the diagnostic wavelengths. The
actual range of the diagnostic wavelengths may slightly differ from
reference material to reference material too. This does not present a
problem however because when a sample is presented to a comparison
software such as the USGS Tetracorder (as an example), the presented
sample spectrum is compared to the whole spectral library where the
comparison criteria is estimated for every sample in the library. It is
such that one reference material may indicate an absence of a specified
clay mineral, while a different sample of the same type of reference
material may indicate that the clay mineral is in abundance. If there is
a high likelihood that a clay mineral is in abundance from at least one
of the reference materials, it would be considered as confirmatory that
that clay mineral is in fact present and in the presented sample.

As a first step, we can plot the two spectra that correspond to the
kaolinite reference material. An identifying Characteristic of kaolinite
is the doublet spectra feature in the 2200nm region. A similar doublet
feature is also present in the 1400nm region too. The absorption
wavelengths near 1400 nm are due to overtones of the O-H stretch
vibration near 2778 nm (3600 cm-1), while those near 2200nm are due to
Al-OH bend plus O-H stretch combinations (Stenberg et al. 2010).
Subsequently water or soil moisture could have a stronger attenuating
effect on the spectra in the 1400nm region compared to 2200nm region
because of these different overtone properties.

    wavelength<-seq(350,2500,by =1) 
    plot(wavelength, (t(mineral_ref$kaolinite_114)), type = "l", col="blue", ylim= c(0,1), ylab="reflectance") 
    lines(wavelength, (t(mineral_ref$kaolinite_113)), type = "l", col="red")

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-3-1.png)  
 Using the diagnostic wavelength indicated for Kaolinite above we can
trim the spectrum accordingly using the <tt>trimSpec</tt> function from
the <tt>spectroscopy</tt> package

    library(spectroscopy)

    # select reference mineral
    mont_ref<- as.data.frame(t(mineral_ref$kaolinite_114))
    colnames(mont_ref)<- wavelength 

    #diagnostic wavelengths
    lower<- 2078
    upper<- 2267

    #Spectrum trim
    mont_diog1<- trimSpec(mont_ref, wavlimits=range(lower:upper)) 

    #plot
    plot(seq(from=lower, to=upper, by=1),mont_diog1[1,],type="l", xlab="wavelength (nm)", ylab= "reflectance")

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-4-1.png)  
 Next we use the continuum removal procedure to normalise the spectra.
The function we will use is slightly different to the convex hull
function (<tt>filter\_spectra</tt>) used earlier for pre-processing
spectra. We will use a function is called <tt>chBLC\_ext</tt>. In
addition to returning the continuum removed spectra, the
<tt>chBLC\_ext</tt> function also returns the fitted continuum, plus the
vertices needed for calculating the area of the diagnostic spectral
feature, and other outputs that are not that important at the moment.
Essentially we need to input the spectra, together with the
<tt>upper</tt> and <tt>lower</tt> bounds of the diagnostic range. The
parameter <tt>specType</tt> needs to be set to 1 to indicate that we are
performing the function upon reflectance data.

    # Continuum removal function
    mont_diog1.CR<- chBLC_ext(spectra = mont_diog1, lower = lower,upper = upper,specType = 1)

    #Plot
    plot(seq(from=lower, to=upper, by=1),mont_diog1[1,],type="l", xlab="wavelength (nm)", ylab= "reflectance", main = "Continuum fitted to reference material spectrum")

    #Continuum
    lines(seq(from=lower, to=upper, by=1),mont_diog1.CR$continuum,col="red") 

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-6-1.png)  
 We can then plot the continuum normalised spectrum which is just
setting the fitted continuum as 1 then estimating the deviation of the
spectrum reflectance values from the continuum.

    # Plot continuum removed spectra
    plot(seq(from=lower, to=upper, by=1),mont_diog1.CR$c.hull,type="l", xlab="wavelength", ylab="reflectance")

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-7-1.png)  
 \#\# Quantitative parameters of absorbance features

Now we wish to estimate specifically the absorbance feature depth, area
and slope. Following from equation 1, the estimation of band depth can
be scripted as below. All we are doing here is searching for the minimum
reflectance value of the raw spectrum, then searching for the
corresponding value of the continuum at that same wavelength.

    #Band Depth
    feature.bd<-1-(mont_diog1.CR[[3]][which(mont_diog1.CR[[2]]==min(mont_diog1.CR[[2]]))]/mont_diog1.CR[[4]][which(mont_diog1.CR[[2]]==min(mont_diog1.CR[[2]]))])
    feature.bd

    ## [1] 0.3474705

Estimating the area of the polygon is relatively straightforward. The
vertices of the spectral feature have been stored as an element within
the <tt>mont\_diog1.CR</tt> object. We can configure these vertices to
make a polygon after which we calculate the area. For the area
calculation, we use the <tt>areapl</tt> function that comes with the
<tt>splancs</tt> package.

    #Area of absorbance feature
    #Plot
    plot(seq(from=lower, to=upper, by=1),mont_diog1.CR$c.hull,type="l", xlab="wavelength", ylab="reflectance")
    #polygon
    polygon(mont_diog1.CR$polygon, col="red",border=NA)

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-9-1.png)  

    #calculate area
    library(splancs)
    feature.area<- areapl(mont_diog1.CR$polygon)
    feature.area

    ## [1] 21.25592

Lastly calculating the slope of the continuum is just the value of the
continuum at the smallest wavelength subjected from the value of the
continuum at the largest wavelength.

    feature.slope<-mont_diog1.CR[[4]][length(mont_diog1.CR[[4]])]-mont_diog1.CR[[4]][1] 
    feature.slope

    ## [1] -0.1471

For future reference and for the later comparison, it is handy to store
all the pertinent information that has been gathered regarding each
reference material as one object. Below all the information we have
gathered about the Kaolinite reference material are stored in a
<tt>list</tt> object called <tt>reference.material.summary</tt>. We
would repeat this procedure for all the other reference materials to
build up a library of summaries that could be queried later when we
start to analyse some soil spectra.

    reference.material.summary<- list(name="reference.material", 
                                      wave= seq(lower,upper,by =1), 
                                      CR_spectra = mont_diog1.CR$c.hull, 
                                      band.depth = feature.bd, 
                                      feature.area = feature.area, 
                                      feature.slope= feature.slope, 
                                      continuum=mont_diog1.CR$continuum,  
                                      contiuum.polygon = mont_diog1.CR$polygon, 
                                      raw.spectrum= mont_diog1.CR$wave)

Comparing spectral references with soil spectra
===============================================

This section is dedicated to implementing the task of comparing
diagnostic spectral features of the reference material to the
corresponding features of collected soil spectra. In the data folder for
this exercise is a file titled **refMin\_summaries.RData** which
contains the objects or reference material summaries of the key soil
clay minerals and iron oxides described at the beginning (this saves you
having to complete them all yourself). These will appear in the working
environment if successfully loaded.

    # Load reference material summaries
    load("refMin_summaries.RData")

    #Load necessary libraries
    library(spectroscopy);library(splancs)

Now we can load in the vis-NIR spectra data which is in the file
**NIR\_ssm\_ref.csv**

    # Load spectra data
    spectra<- read.csv("NIR_ssm_ref.csv")

Then we do some data curation to prepare it for analysis. It is at this
stage where you decide whether you implement spectral smoothing of the
raw spectra or not. It is opted out of in the following example.

    #Curation
    nc <- ncol(spectra)
    spec.names<- spectra$sampleID
    spectra <- spectra[, 2:nc] #remove first column
    wavelength <- seq(350, 2500, by = 1) #wavelength sequence
    colnames(spectra) <- wavelength #append column names

If you want you could potentially automate the procedure of checking
each sample for the presence or relative abundance of each reference
material that we have summary information for. In fact this would be a
good advanced exercise to try and implement in R.

The following is just an example of checking 1 one spectrum at a time
the relative abundance to a single selected reference material. In this
case the selected material is one of the kaolinite samples. The example
script below however is pretty flexible that you can change the
reference material and soil spectrum that you want to make the
comparison to.

    #Select the reference material you want to compare soil spectra too
    min.select<- kaolin_114.1.summary

    # Region of Interest
    lower<- min(min.select$wave)
    upper<- max(min.select$wave)
    lower;upper

    ## [1] 2079

    ## [1] 2267

    #select the spectrum
    speczz<- 1

Spectral trimming is next. The next script using the <tt>specTrim</tt>
function, will actually perform the trimming upon the whole spectral
dataset in one go.

    #Spectral Trim
    specTrim<- trimSpec(spectra = spectra, wavlimits=range(lower:upper)) 

    #Plot single spectrum
    plot(seq(from=lower, to=upper, by=1),specTrim[speczz,],type="l", xlab= "wavelength", ylab = "reflectance")

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-16-1.png)  
 Then we can fit the continuum to this spectrum.

    #Convex Hull and continuum
    spec.CR<- chBLC_ext(specTrim[speczz,], lower, upper,specType = 1)

    #Plot continuum
    plot(seq(from=lower, to=upper, by=1),specTrim[speczz,],type="l", xlab= "wavelength", ylab = "reflectance")
    lines(seq(from=lower, to=upper, by=1),spec.CR$continuum,col="red") 

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-17-1.png)  

    # normalised spectra
    plot(seq(from=lower, to=upper, by=1),spec.CR$c.hull,type="l", xlab="wavelength", ylab="reflectance")

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-17-2.png)  
 We can then calculate the various quantitative parameters that describe
the absorbance features within this spectral range.

    #Band depth
    spec.bd<-1-(spec.CR[[3]][which(spec.CR[[2]]==min(spec.CR[[2]]))]/spec.CR[[4]][which(spec.CR[[2]]==min(spec.CR[[2]]))])
    spec.bd

    ## [1] 0.03211416

    #area of spectral feature
    spec.area<- areapl(spec.CR[[5]])
    spec.area

    ## [1] 1.685146

    #slope of continuum
    spec.slope<-spec.CR[[4]][length(spec.CR[[4]])]-spec.CR[[4]][1] 
    spec.slope

    ## [1] -0.01244511

Now we can start comparing the spectral feature of this spectrum to that
of the reference material. First we estimate the correlation between the
normalised spectra of the reference material to the soil spectrum. This
measure provides an indicator of the similarity in shape between both
features.

    #Correlation 
    spec.fit<- as.numeric(cor(t(spec.CR$c.hull), t(min.select$CR_spectra)))
    spec.fit

    ## [1] 0.8547527

Then we calculate the relativity parameters to spectral depth and area
of the reference material. We can then also estimate relative abundance
of the target mineral by applying equation 2 above.

    # relative depth
    r.bd<- as.numeric(spec.bd/min.select$band.depth)
    r.bd

    ## [1] 0.09246652

    #relative area
    r.area<- as.numeric(spec.area/min.select$continuum.area)
    r.area

    ## [1] 0.0795061

    #fit x relative depth
    spec.fit*r.bd

    ## [1] 0.07903601

    #fit x depth x area
    spec.fit*r.bd*r.area

    ## [1] 0.006283845

The relative abundance of kaolinite in this sample seems pretty low. A
helpful plot is to overlay the normalised plot of the soil spectrum upon
the reference material. This plot pretty well confirms the low relative
abundance too.

For a contrasting example, you should repeat the above procedure using
the 100th spectrum in the supplied spectra dataset.

    #Plot reference material
    plot(seq(from=lower, to=upper, by=1),min.select$CR_spectra, type="l", col="blue", ylab="continuum removed reflectance", xlab="wavelength", main=spec.names[speczz] )

    #soil 
    lines(seq(from=lower, to=upper, by=1),spec.CR$c.hull, col="red")

![](visNIR_mineralDetector_files/figure-markdown_strict/unnamed-chunk-21-1.png)  
 \#\# Exercise With some basic introduction to the key concepts of soil
mineral detection via spectral feature comparison you should explore the
relative abundances using other spectra in the supplied dataset.
Furthermore you should also explore the relative abundances of other
reference materials that you have been supplied with. For example assess
for the relative abundance of Hematite or smectite.

References
==========

Brown, D.J., K.D. Shepherd, M.G. Walsh, M.D. Mays, and T.G. Reinsch.
2006. “Global Soil Characterization with VNIR Diffuse Reflectance
Spectroscopy.” *Geoderma* 132 (3-4): 273–90.

Clark, R.N., and T.L Roush. 1984. “Refectance Spectroscopy -
Quantitative Analysis Techniques for Remote Sensing Applications.”
*Journal of Geophysical Research*, no. 89(NB7): 6329–40.

Clark, R.N., T.V.V. King, M. Klejwa, G.A. Swayze, and N. Vergo. 1990.
“High Spectral Resolution Reflectance Spectroscopy of Minerals.”
*Journal of Geophysical Research-Solid Earth and Planets* 95 (B8):
12653–80.

Clark, R.N., G.A. Swayze, K.E. Livo, R.F. Kokaly, S.J. Sutley, J.B.
Dalton, R.R. McDougal, and C.A. Gent. 2003. “Imaging Spectroscopy: Earth
and Planetary Remote Sensing with the USGS Tetracorder and Expert
Systems.” *Journal of Geophysical Research-Planets* 108 (E12): 1–44.

Clark, R.N., G.A. Swayze, R. Wise, K.E. Livo, T.M. Hoefen, R.F. Kokaly,
and S.J. Sutley. 2007. “USGS Digital Spectral Library Splib06a.”
*Geological Survey, Data Series* 231.

Stenberg, Bo, Raphael A. Viscarra Rossel, Abdul Mounem Mouazen, and
Johanna Wetterlind. 2010. “Chapter Five - Visible and Near Infrared
Spectroscopy in Soil Science.” In, edited by Donald L. Sparks,
107:163–215. Advances in Agronomy. Academic Press.
doi:[http://dx.doi.org/10.1016/S0065-2113(10)07005-7](http://dx.doi.org/http://dx.doi.org/10.1016/S0065-2113(10)07005-7).

Viscarra Rossel, R.A., S.R. Cattle, A. Ortega, and Y. Fouad. 2009. “In
Situ Measurements of Soil Colour, Mineral Composition and Clay Content
by Vis-NIR Spectroscopy.” *Geoderma* 150 (3-4): 253–66.
