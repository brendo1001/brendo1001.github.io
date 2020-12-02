---
layout: page
title: Interactive mapping using R
description: "My own original content"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-04-27
---

A step beyond creating kml files of your digital soil information is the
creation of customized interactive mapping products that can be
visualized within your web browser. Some notes about how to do this using R are given in our [book](http://www.springer.com/gp/book/9783319443256) and with example [here]({{ site.url }}/DSM_book/pdfs/P3_1_RGIS_2017.pdf). I wanted to teach myself how i might be able to embed these interactive maps into a website, so i created an example to help me. In doing this i hope others who have not come across interactive mapping before are able to get some basic insights about it.  


Interactive mapping makes sharing
your data with colleagues simpler, and importantly improves the
visualization experience via customization features that are difficult
to achieve via the Google Earth software platform. The interactive
mapping is made possible via the Leaflet R package. Leaflet is one of
the most popular open-source JavaScript libraries for interactive maps.
The Leaflet R package makes it easy to integrate and control Leaflet
maps in R. More detailed information about Leaflet can be found
[here](http://leafletjs.com/), and information specifically about the R
package is [here](https://rstudio.github.io/leaflet/).

There is a common workflow for creating Leaflet maps in R. First is the
creation of a map widget (calling ); followed by the adding of layers or
features to the map by using layer functions (e.g. `addTiles`,
`addMarkers`, `addPolygons`) to modify the map widget. The map can then
be printed and visualized in the R image window or saved to HTML file
for visualization within a web browser or even embed it into a website
like the one you are reading. The following R script is a quick taste of
creating an interactive Leaflet map. It is assumed that the `leaflet`
and `magrittr` packages are installed.

First lets get our workflow initialised by loading up our R packages.

```r
    # Required R Packages
    library(leaflet)
    library(magrittr)
    library(ithir)
    library(sp)
    library(raster)
    library(RColorBrewer)
    library(rgdal)
```

### Point Data

We will be working with a small data set of soil information that was
collected from the Hunter Valley, NSW in 2010 called . This data set is
contained in the package. So first load it in:

```r
    data(HV100)
    str(HV100)

    ## 'data.frame':    100 obs. of  6 variables:
    ##  $ site: Factor w/ 100 levels "a1","a10","a11",..: 1 2 3 4 5 6 7 8 9 10 ...
    ##  $ x   : num  337860 344060 347035 338235 341760 ...
    ##  $ y   : num  6372416 6376716 6372741 6368766 6366016 ...
    ##  $ OC  : num  2.03 2.6 3.42 4.1 3.04 4.07 2.95 3.1 4.59 1.77 ...
    ##  $ EC  : num  0.129 0.085 0.036 0.081 0.104 0.138 0.07 0.097 0.114 0.031 ...
    ##  $ pH  : num  6.9 5.1 5.9 6.3 6.1 6.4 5.9 5.5 5.7 6 ...
```

Using the `coordinates` function from the `sp` package we can define
which columns in the data frame refer to actual spatial coordinates---
here the coordinates are listed in columns `x` and `y`.

```r
    coordinates(HV100) <- ~x + y
    str(HV100)

    ## Formal class 'SpatialPointsDataFrame' [package "sp"] with 5 slots
    ##   ..@ data       :'data.frame':  100 obs. of  4 variables:
    ##   .. ..$ site: Factor w/ 100 levels "a1","a10","a11",..: 1 2 3 4 5 6 7 8 9 10 ...
    ##   .. ..$ OC  : num [1:100] 2.03 2.6 3.42 4.1 3.04 4.07 2.95 3.1 4.59 1.77 ...
    ##   .. ..$ EC  : num [1:100] 0.129 0.085 0.036 0.081 0.104 0.138 0.07 0.097 0.114 0.031 ...
    ##   .. ..$ pH  : num [1:100] 6.9 5.1 5.9 6.3 6.1 6.4 5.9 5.5 5.7 6 ...
    ##   ..@ coords.nrs : int [1:2] 2 3
    ##   ..@ coords     : num [1:100, 1:2] 337860 344060 347035 338235 341760 ...
    ##   .. ..- attr(*, "dimnames")=List of 2
    ##   .. .. ..$ : chr [1:100] "1" "2" "3" "4" ...
    ##   .. .. ..$ : chr [1:2] "x" "y"
    ##   ..@ bbox       : num [1:2, 1:2] 335160 6365091 350960 6382816
    ##   .. ..- attr(*, "dimnames")=List of 2
    ##   .. .. ..$ : chr [1:2] "x" "y"
    ##   .. .. ..$ : chr [1:2] "min" "max"
    ##   ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
    ##   .. .. ..@ projargs: chr NA
```

Note now that by using the `str` function, the class of `HV100` has now
changed from a `dataframe` to a `SpatialPointsDataFrame`. The
`SpatialPointsDataFrame` structure is essentially the same data frame,
except that additional spatial elements have been added or partitioned into slots. Some important ones being the bounding box (sort of like the spatial extent of the data), and the coordinate reference system (`proj4string`), which we need to define for our data set. To define the CRS, we have to know some things about where our data are from, and what was the corresponding CRS used when recording the spatial information in the field. For this data set the CRS used was WGS1984 UTM Zone 56. To explicitly tell R this information we define the CRS as a character string which describes a reference system in a way understood by the [PROJ.4 projection library](http://trac.osgeo.org/proj/). An interface to the PROJ.4 library is available in the`rgdal`package. Alternative to using Proj4 character strings, we can use the corresponding yet simpler EPSG code (European Petroleum Survey Group).`rgdal`
also recognizes these codes. If you are unsure of the Proj4 or EPSG code
for the spatial data that you have, but know the CRS, you should consult
[Spatial Reference](http://spatialreference.org/) for assistance. The
EPSG code for WGS1984 UTM Zone 56 is: 32556. So lets define to CRS for
this data.

```r
    proj4string(HV100) <- CRS("+init=epsg:32756")
    HV100@proj4string

    ## CRS arguments:
    ##  +init=epsg:32756 +proj=utm +zone=56 +south +datum=WGS84 +units=m
    ## +no_defs +ellps=WGS84 +towgs84=0,0,0
```

To look at the locations of the data in Google Earth, we first need to
make sure the data is in the WGS84 geographic CRS. If the data is not in
this CRS (which is not the case for this data), then we need to perform
a coordinate transformation. This is facilitated by using the
`spTransform` function in `sp`. The EPSG code for WGS84 geographic is:
4326. We can then export out our transformed HV100 data set to a KML
file and visualize it in Google Earth. We will use it later for our
interactive web mapping.

```r
    HV100.ll <- spTransform(HV100, CRS("+init=epsg:4326"))
    #Export KML
    #writeOGR(HV100.ll, "HV100.kml", "ID", "KML")
```

### Rasters

Most of the functions needed for handling raster data are contained in
the `raster` package. There are functions for reading and writing raster
files from and to different raster formats. In DSM we work quite a deal
with data in table format and then rasterise this data so that we can
make a map. To do this in R, lets bring in a `data frame`. This could be
either from a text-file, but as for the previous occasions the data is
imported from the `ithir` package. This data is a digital elevation
model with 100m grid resolution, from the Hunter Valley, NSW, Australia.

```r
    data(HV_dem)
    str(HV_dem)

    ## 'data.frame':    21518 obs. of  3 variables:
    ##  $ X        : num  340210 340310 340110 340210 340310 ...
    ##  $ Y        : num  6362641 6362641 6362741 6362741 6362741 ...
    ##  $ elevation: num  177 175 178 172 173 ...
```

As the data is already a raster (such that the row observation indicate
locations on a regular spaced grid), but in a table format, we can just
use the `rasterFromXYZ` function from `raster`. Also we can define the
CRS just like we did with the `HV100` point data we worked with before.

```r
    r.DEM <- rasterFromXYZ(HV_dem)
    proj4string(r.DEM) <- CRS("+init=epsg:32756")
```

For web mapping and associated Google Earth mapping, remember that we
need to reproject our data because it is in the UTM system, and need to
get it to WGS84 geographic. The raster re-projection is performed using
the `projectRaster` function. Look at the help file for this function.
Probably the most important parameters are `crs`, which takes the CRS
string of the projection you want to convert the existing raster to,
assuming it already has a defined CRS. The other is `method` which
controls the interpolation method. For continuous data,
`bilinear` would be suitable, but for categorical,`ngb`, (which is
nearest neighbor interpolation) is probably better suited.

```r
    p.r.DEM <- projectRaster(r.DEM, crs = "+init=epsg:4326", method = "bilinear")
```

### Interactive Mapping

Now we have our data. Lets first provide an example of what is meant by
an interactive map. Explaination is to follow.

```r
    leaflet() %>% 
      addMarkers(lng = 151.210558, lat = -33.852543, 
        popup = "The view from here is amazing!") %>% 
      addProviderTiles("Esri.WorldImagery") 
```


{% include htmlwidgets/m1.html %}



Interactive features of this map include markers with text, plus ability
to zoom and map panning. More will be discussed about the layer
functions of the leaflet map further on. What has not been encountered
yet is the forward pipe operator `%>%`. This operator will forward a
value, or the result of an expression, into the next function call or
expression. To use this operator the `magrittr` package is required. The
example script below shows the same example using and not using the
forward pipe operator.

```r
    #Draw 100 random uniformly distributed numbers between 0 and 1
    x <- runif(100)

    sqrt(sum(range(x)))

    ## [1] 1.005229

    ##..is equivalent to (using forward pipe operator)
    x %>% range %>% sum %>% sqrt

    ## [1] 1.005229
```

Sometimes what we want to do in R can get lost within a jumble of
brackets, whereas using the forward pipe operator the process of
operations is a lot clearer. So lets begin to construct some Leaflet
mapping using our prepared data from a little earlier regarding the
point (`HV100.ll`) and raster data (`p.r.DEM`). Firstly, lets create a
basic map --- example of not using and then using the forward pipe
operator.

```r
    # Basic map
    #without piping operator
    addMarkers(addTiles(leaflet()), data = HV100.ll)

    #with forward pipe operator
    leaflet() %>%  
      addTiles() %>% 
      addMarkers(data = HV100.ll)
```


{% include htmlwidgets/m2.html %}



With the above, we are calling upon a pre-existing base map via the
`addTiles()` function. Leaflet supports base maps using map tiles,
popularized by Google Maps and now used by nearly all interactive web
maps. By default,
[OpenStreetMap](https://www.openstreetmap.org/#map=13/-33.7760/150.6528&layers=C)
tiles are used. Alternatively, many popular free third-party base maps
can be added using the `addProviderTiles()` function, which is
implemented using the leaflet-providers plugin. For example, previously
we used the `Esri.WorldImagery` base mapping. The full set of possible
base maps can be found
[here](http://leaflet-extras.github.io/leaflet-providers/preview/index.html).
Note that an internet connection is required for access to the base maps
and map tiling. The last function used above the the `addMarkers`
function, we we simply call up the point data we used previously, which
are those soil point observations and measurements from the Hunter
Valley, NSW. A basic map will have been created with your plot window.
For the next step, lets populate the markers we have created with some
of the data that was measured, then add the `Esri.WorldImagery` base
mapping.

```r
    # Populate pop-ups
    my_pops <- paste0(
      "<strong>Site: </strong>", 
      HV100.ll$site,
      '<br>
      <strong> Organic Carbon (%): </strong>', 
      HV100.ll$OC, 
      '<br>
      <strong> soil pH: </strong>', 
      HV100.ll$pH
    )

    # Create interactive map
    leaflet() %>% 
      addProviderTiles("Esri.WorldImagery") %>% 
      addMarkers(data = HV100.ll, popup = my_pops)
```

Further, we can colour the markers and add a map legend. Here we will
get the quantiles of the measured SOC percentage and color the markers
accordingly. Note that you will need the colour ramp package
`RColorBrewer` installed.

```r
    # Colour ramp
    pal1 <- colorQuantile("YlOrBr", domain = HV100.ll$OC)

    # Create interactive map
    leaflet() %>% 
      addProviderTiles("Esri.WorldImagery") %>% 
      addCircleMarkers(data = HV100.ll, color = ~pal1(OC), popup = my_pops) %>% 
      addLegend("bottomright", pal = pal1, values = HV100.ll$OC,
                title = "Soil Organic Carbon (%) quantiles",
                opacity = 0.8
      )
```

It is very worth consulting the help files associated with the `leaflet`
R package for further tips on creating further customized maps. The
website dedicated to that package, which was mentioned above is also a
very helpful resource too.

Raster maps can also be featured in our interactive mapping too, as
illustrated in the following script.

```r
    #Colour ramp
    pal2 <- colorNumeric(
      brewer.pal(n = 9, name = "YlOrBr"), 
      domain = values(p.r.DEM), 
      na.color = "transparent"
    )

    #interactive map
    leaflet() %>% 
      addProviderTiles("Esri.WorldImagery") %>% 
      addRasterImage(p.r.DEM, colors = pal2, opacity = 0.7) %>%
      addLegend("topright", opacity=0.8, pal = pal2, values = values(p.r.DEM), 
                title = "Elevation")
      )
```


{% include htmlwidgets/m3.html %}



Lastly, we can create an interactive map that allows us to switch
between the different mapping that we have created.

```r
    #layer switching
    leaflet() %>% 
      addTiles(group = "OSM (default)") %>%
      addProviderTiles("Esri.WorldImagery") %>% 
      
      addCircleMarkers(data = HV100.ll, color = ~pal1(OC), 
                    group = "points", popup = my_pops) %>% 
      addRasterImage(p.r.DEM, colors = pal2,group = "raster", 
                     opacity = 0.8) %>%
      addLayersControl(
        baseGroups = c("OSM (default)", "Imagery"),
        overlayGroups = c("points", "raster"))
```

{% include htmlwidgets/m4.html %}



With the created interactive mapping, we can then export these as a web
page in HTML format. This can be done via the export menu within the
R-Studio plot window, where you want to select the option for `Save
as Web page`. This file can then be easily shared and viewed by your
colleagues.

These examples above are just scraping the top of what can be done with interactive maps. Later on i might follow up with examples using new R packages such as `mapview` and `sf` which from what i have read about seem to make things much easier.  
