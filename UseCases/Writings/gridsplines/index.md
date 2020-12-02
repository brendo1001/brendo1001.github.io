---
layout: page
title: Customising public digital soil mapping products with mass preserving splines
description: "My own original content"
header-img: images/worldSoilDay.jpg
comments: false
modified: 2020-04-27
---

*There are now plenty of soil maps which digitally represent the soil variation across landscapes in both the lateral and vertical dimensions. Some might say this is akin to digital twinning for natural resources. These representations are usually provided as depth slices or layers for specified depth intervals. What is probably not as widely known or practiced is that one can use these data to generate custom soil maps (in terms of vertical support representation) according to the wishes of the end-user or map maker. In this post, the mass-preserving spline is re-introduced not for harmonising soil profile data, but for creating user-defined soil maps that exploit 3D digital soil mapping information that are becoming widely available publicly and for free.*


### A background story of sorts

There do not appear to be new official global activities associated with the [GlobalSoilMap.net](https://www.isric.org/projects/globalsoilmapnet) project (Sanchez et al. 2009) any longer. This initiative was very active between 2009 and 2013 and created a flurry of efforts to map the world’s soils and their characteristics. The initial philosophy of GlobalSoilMap.net was for nodes to coordinate activities across a selected number of regions and individual countries would work within the nodes to develop digital soil mapping products for within country, and provide assistance to other countries in the region where the necessary digital soil mapping skill base was still in development.

Probably the greatest success and lasting legacy of the GlobalSoilMap.net project was the creation of a document that specified the expected outputs to be developed i.e. the GlobalSoilMap.net specifications (Arrouays et al. 2014). These specifications have guided digital soil mapping practices throughout the world since they were published. Global soil mapping efforts now are coordinated a little differently and mainly through the auspices of the [Global Soil Parntership](http://www.fao.org/global-soil-partnership/en/). One of the main GlobalSoilMap.net specifications was the requirement to produce maps for the following soil properties: SOC, clay, silt, sand and coarse fragment contents, pH, ECEC, soil depth and available depth to rooting, bulk density (whole soil and fine earth fraction), and available water capacity at standard depths to 2m. Specifically for the depth intervals of: 0-5cm, 5-15cm, 15-30cm, 30-60cm, 60-100cm, 100-200cm.

Early research was dedicated to figuring out approaches for generating digital maps for the specified standard depths given legacy soil profile data and the existing digital soil mapping techniques. The mass preserving spline (Bishop, McBratney, and Laslett 1999) became a critical methodological advancement in this regard as it enabled soil profile data all with disparate depth information to be harmonised. The spline was fitted to the soil profile data and this depth function is then integrated to get the target soil property values for the standard depths or any specified depth intervals or set of depth intervals according to the user. The mass preserving spline is super useful and its mass preserving properties mean that the original soil profile information is never lost after the function is fitted. In a digital soil mapping context, first soil profile data is gathered, the splines are fitted individually to each profile from which the soil target variables at each standard depth is retrieved. Then spatial models are fitted for each depth using a collected suite of environmental covariate layers as predictor variables. This is the general approach undertaken in Malone et al. (2009) which has also been done too throughout the world. While this approach remains popular, different 3D spatial modelling approaches have evolved (see for example Hengl (2017), Orton, Pringle, and Bishop (2016), Viscarra Rossel et al. (2015), and Poggio and Gimona (2014)). But ultimately, the end result from whatever approach is used are digital soil maps of specific variables at each standard depth. The depth support of these maps is supposedly representing an average of the specified target variable for the given standard depth. This is the case for the Malone et al., Orton et al., Viscarra Rossel et al. and Poggio and Gimona approaches, but likely not for the Hengl et al. approach where the values are indicative of the mid-point between the upper and lower depths standard intervals. Technical differences aside, most maps are generated at a point support for a specified grid cell or pixel resolution which for the global soil mapping specifications was ~90m on the basis of the 3-sec STRM DEM which became readily available around the same time as the launching of GlobalSoilMap.

So there is now seemingly a proliferation of digital soil maps covering all parts of the world, all produced in a way that meet or closely adhere to the specifications set out in Arrouays et al. (2014). Australia is one of these places, and the efforts are described in Grundy et al. (2015). The great thing about this effort (The Soil and Landscape Grid of Australia; SLGA) is now these data are available for everyone to retrieve and importantly use for any number of purposes that requires spatial soil information. [This data is easy to access and download](https://www.clw.csiro.au/aclep/soilandlandscapegrid/GetData-DAP.html#). If one is an `R` user there is now even a package, [slga](https://cran.r-project.org/web/packages/slga/index.html) that facilitates easy access and download of specified soil and environment data. We will get onto more of this package later.

### An opportunity

How to make use of the available digital soil maps poses some follow up questions. It is great to be able to have a 3-D digital representation of soils, in some ways akin to a digital twin. But without necessary tools with which to analyse the representations of these data i.e. interrogating and integrating the 0-5cm,5-15cm, 15-30cm, 30-60cm, 60-100cm, and 100-200cm layers, one will be limited in realising the utility of this information. One tool to be described in this post is the mass-preserving spline which we were just introduced to earlier in regards to harmonising soil profile data. Essentially the soil target variable data together with information about corresponding depths intervals are parameters of the spline. Therefore where there is layered and gridded digital soil maps we basically can fit a spline at each grid cell and then interrogate the fitted spline to generate new outputs at a different vertical support. This allows one to customise their soil mapping information to a form that is conducive for their own particular analysis. Furthermore a step forwards on this is that one can facilitate inferences as was exemplified in Malone et al. (2009) where variables such as depth to which carbon stocks breached a given threshold value, or estimated the water holding capacity to a given depth etc. One can even get more sophisticated around inference for such things as detecting depth to a texture contrast layer or to some given soil constraint. The important key point here is that the layered 3D representation of soil information as specified for GlobalSoilMap or for any other similar product, is that there is added utility of this information beyond the base maps.

This post intends to exemplify the splines approach for 3D soil mapping products using the the SLGA data and associated R package as the vehicle for doing this. At the moment the code for doing this comes from a bespoke R function called `ea_ras_func` and can be download from [here](https://www.dropbox.com/s/0rmrsfl6pk7p9gj/ea_ras_func.R?dl=0). For all intents and purposes the function is the same as would be used to fit to soil profile data but is streamlined for grid data. Another key point is that as there are no gaps between sol values as the layers are adjacent to one another, there is no interpolation, meaning that the mass-preserving properties of the spline are much easier to adhere to.

### Let’s get on with it

To get a bit more background about the [slga](https://cran.r-project.org/web/packages/slga/index.html)`R` package it is worth checking out the vignette that comes with the package that you can open once it is installed. This package is available from [CRAN](https://cran.r-project.org/).

```r
install.packages("slga")
```

Load the `R` packages required and the function for spline fitting.

```r
# The grid spline function
source("ea_ras_func.R")

# R libraries
library(raster)
library(slga)
```

The next bits of code are for download of the SLGA maps. This is pretty much verbatim what is done in the slga `R` package vignette.

```r
# Get surface clay content for King Island

# Area of interest (aka bounding box)
aoi <- c(149.00, -35.50, 149.1, -35.40)

# Get the data
s1<- stack()

for (i in 1:6){
    r1 <- get_soils_data(product = 'NAT', attribute = 'CLY', component = 'VAL', depth = i, aoi = aoi, write_out = FALSE)
    s1<- stack(s1,r1)}

# raster stack of all rasters (each layer is a depth)
s1

## class      : RasterStack 
## dimensions : 121, 121, 14641, 6  (nrow, ncol, ncell, nlayers)
## resolution : 0.0008333333, 0.0008333333  (x, y)
## extent     : 148.9996, 149.1004, -35.50042, -35.39958  (xmin, xmax, ymin, ymax)
## crs        : +init=epsg:4283 +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs 
## names      : NAT_CLY_VAL_000_005, NAT_CLY_VAL_005_015, NAT_CLY_VAL_015_030, NAT_CLY_VAL_030_060, NAT_CLY_VAL_060_100, NAT_CLY_VAL_100_200 
## min values :            7.735192,            8.906991,           12.726418,           18.109673,           21.137390,           22.203936 
## max values :            32.54842,            33.97256,            38.32691,            44.41605,            45.26889,            44.36512

# plot
plot(s1)
```    

<figure>
    <img src="{{ site.url }}/images/20200204gridsplines/unnamed-chunk-3-1.png" alt="SLGA1">
    <figcaption>Figure 1. Digital soil maps of clay content for King Island. Depth support corresponds to GlobalSoilMap standard depths.</figcaption>
</figure>


The workhorse function in the code above is the `get_soils_data`. Here we are downloading from the national data repository space (as opposed to getting state-based estimates which may or may not be of improved prediction certainty) for each of the GSM standard depths. We are just downloading the values, but keep in mind that one can also get the associated prediction uncertainties too. Check out the help file for this function for other goodies one can do with it. Basically we are downloading each layer of data within the defined area of interest which in this case is King Island.

Using the `ea_rasSp` function is relatively straightforward. Basically it will only ingests a raster stack. The function automatically assumes each raster layer represents a 3D soil representation, which could be GSM standard depths or some other representation. We specify this with the `dIn` parameter where `dIn = c(0,5,15,30,60,100,200)` corresponds to the GSM depths i.e. 0-5cm, 5-15cm, 15-30cm, 30-60cm, 60-100cm and 100-200cm. `dOut` is the parameter for the new depth intervals we want. Below we a signalling (just to be unusual) to get the 0-11cm, 11-25cm, 25-31cm, 21-50cm, and 50-180cm depth intervals. The `vlow` and `vhigh` parameters are for constraining the spline fit to be within normal ranges which for soil texture is between 0% and 100%. The other important parameter is `lam` which determines the amount of flex in the fitted spline. The value 0.1 is usually a acceptable choice, but one can select their own choice based on there own criteria. High values result in stiff splines while low values result in flexible splines.

```r
# use raster spline function 
s1.new<- ea_rasSp(obj= s1, # raster stack object
             lam = 0.1, # lambda
             dIn = c(0,5,15,30,60,100,200), # These are SLGA standard depths (but could be any depths though)
             dOut = c(0,11,25,31,50,180),   # User specified depths
             vlow = 0, 
             vhigh = 100,
             show.progress=FALSE)

s1.new

## class      : RasterStack 
## dimensions : 121, 121, 14641, 5  (nrow, ncol, ncell, nlayers)
## resolution : 0.0008333333, 0.0008333333  (x, y)
## extent     : 148.9996, 149.1004, -35.50042, -35.39958  (xmin, xmax, ymin, ymax)
## crs        : NA 
## names      :   X0.11cm,  X11.25cm,  X25.31cm,  X31.50cm, X50.180cm 
## min values :  8.282192, 11.591473, 14.621008, 17.420295, 21.637719 
## max values :  33.22039,  36.88600,  40.41217,  43.74120,  44.77895

# make a plot
plot(s1.new)
```

<figure>
    <img src="{{ site.url }}/images/20200204gridsplines/unnamed-chunk-4-1.png" alt="SLGA2">
    <figcaption>Figure 1. Digital soil maps of clay content for King Island. Depth support corresponds to the depths as requested; 0-11cm, 11-25cm,
25-31cm, 21-50cm, and 50-180cm depth intervals.</figcaption>
</figure>

Probably a more usual thing to do might be to get to top 10cm, then 10-30cm, and finally 30-100cm.

```r
# use raster spline function 
s1.newer<- ea_rasSp(obj= s1, # raster stack object
             lam = 0.1, # lambda
             dIn = c(0,5,15,30,60,100,200), # These are SLGA standard depths (but could be any depths though)
             dOut = c(0,10,30,100),   # User specified depths
             vlow = 0, 
             vhigh = 100,
             show.progress=FALSE)

s1.newer

## class      : RasterStack 
## dimensions : 121, 121, 14641, 3  (nrow, ncol, ncell, nlayers)
## resolution : 0.0008333333, 0.0008333333  (x, y)
## extent     : 148.9996, 149.1004, -35.50042, -35.39958  (xmin, xmax, ymin, ymax)
## crs        : NA 
## names      :   X0.10cm,  X10.30cm, X30.100cm 
## min values :  8.190432, 12.196100, 19.818838 
## max values :  33.11356,  37.59536,  44.84079

# make a plot
plot(s1.newer)
```

<figure>
    <img src="{{ site.url }}/images/20200204gridsplines/unnamed-chunk-5-1.png" alt="SLGA3">
    <figcaption>Figure 1. Digital soil maps of clay content for King Island. Depth support corresponds to the depths as requested; 0-10cm, 10-30cm, cm, and 30-100cm depth intervals.</figcaption>
</figure>


### A final word

There is not too much more to this piece of work. The intention here was to illustrate that the outputs commonly generated in digital soil mapping that adhere the GSM specifications have much greater utility than just the standard depth intervals. The `ea_rasSp` is very much a beta version at this stage and could do with vectorisation and optimisation of compute. For now the workflow is a pixel-to-pixel routine. The actual spline fitting is super fast even without optimisation, but the sequential nature of pixel-to-pixel quickly ramps up the compute time for highly populated grids. Currently it would be useful for farm to regional extent soil mapping work as it is, but could indeed be parallelised for much larger extents without too much tinkering.

The spline is a very useful tool for utilising such maps and enabling one to develop their own customised maps with relatively little effort. An example application of this would be the creation of digital soil maps where the new depth intervals correspond to measurement depths of a network of soil moisture sensors across a field or farm. Or estimating carbon stocks to 1m (a simple average may suffice in this case), or to some customised depths etc. I could be argued that the spline model be used on the soil profile data to generate information to custom depths, and them model. And this maybe the suggested route, but here we are working under the assumption that we don’t have this point data and only have the raster data, of course which is publicly available. In any case, the take home message is just don’t settle for what digital soil information is available to you. Instead, derive the information to suit your needs and your specifications!

References
----------

Arrouays, Dominique, Alex Mcbratney, Budiman Minasny, Jonathan Hempel, Gerard Heuvelink, R.A. Macmillan, Alfred Hartemink, P. Lagacherie, and Neil McKenzie. 2014. “The Globalsoilmap Project Specifications.” *GlobalSoilMap: Basis of the Global Spatial Soil Information System - Proceedings of the 1st GlobalSoilMap Conference*, January, 9–12. <https://doi.org/10.1201/b16500-4>.

Bishop, T.F.A., A.B. McBratney, and G.M. Laslett. 1999. “Modelling Soil Attribute Depth Functions with Equal-Area Quadratic Smoothing Splines.” *Geoderma* 91 (1): 27–45. <https://doi.org/https://doi.org/10.1016/S0016-7061(99)00003-8>.

Grundy, M. J., R. A. Viscarra Rossel, R. D. Searle, P. L. Wilson, C. Chen, and L. J. Gregory. 2015. “Soil and Landscape Grid of Australia.” *Soil Res.* 53 (8): 835–44. <https://doi.org/10.1071/SR15191>.

Hengl, Jorge AND Heuvelink, Tomislav AND Mendes de Jesus. 2017. “SoilGrids250m: Global Gridded Soil Information Based on Machine Learning.” *PLOS ONE* 12 (2). Public Library of Science: 1–40. <https://doi.org/10.1371/journal.pone.0169748>.

Malone, B.P., A.B. McBratney, B. Minasny, and G.M. Laslett. 2009. “Mapping Continuous Depth Functions of Soil Carbon Storage and Available Water Capacity.” *Geoderma* 154 (1): 138–52. <https://doi.org/https://doi.org/10.1016/j.geoderma.2009.10.007>.

Orton, T.G., M.J. Pringle, and T.F.A. Bishop. 2016. “A One-Step Approach for Modelling and Mapping Soil Properties Based on Profile Data Sampled over Varying Depth Intervals.” *Geoderma* 262: 174–86. <https://doi.org/https://doi.org/10.1016/j.geoderma.2015.08.013>.

Poggio, Laura, and Alessandro Gimona. 2014. “National Scale 3D Modelling of Soil Organic Carbon Stocks with Uncertainty Propagation — an Example from Scotland.” *Geoderma* 232-234: 284–99. <https://doi.org/https://doi.org/10.1016/j.geoderma.2014.05.004>.

Sanchez, Pedro A., Sonya Ahamed, Florence Carré, Alfred E. Hartemink, Jonathan Hempel, Jeroen Huising, Philippe Lagacherie, et al. 2009. “Digital Soil Map of the World.” *Science* 325 (5941). American Association for the Advancement of Science: 680–81. <https://doi.org/10.1126/science.1175084>.

Viscarra Rossel, R. A., C. Chen, M. J. Grundy, R. Searle, D. Clifford, and P. H. Campbell. 2015. “The Australian Three-Dimensional Soil Grid: Australia’s Contribution to the &lt;i&gt;GlobalSoilMap&lt;/I&gt; Project.” *Soil Res.* 53 (8): 845–64. <https://doi.org/10.1071/SR14366>.