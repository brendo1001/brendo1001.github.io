# ******************************************************************************
# *                                                                            
# *                           [Leaflet map for inclusion into personal website]                                
# *                                                                            
# *  Description:                                                              
# *  Using supplied data this script runs through a R scripted workflow for making interactive maps using the leaflet R package.
# *  There is no original code here and what is provided is simply that cobbled together freely available from various online sources but contexturalised to the data provided as is.

# *  Created By:                                                               
# *  Brendan Malone                                                
# *                                                                            
# *  Last Modified:                                                            
# *  2023-09-11               
# *                                                                            
# *  License:   
# *     Data Usage License (Data-UL)                                             
# *                                                                            
# *   Permission is hereby granted, free of charge, to any person obtaining a    
# *   copy of this data and associated code files (the "Data"), to use the Data  
# *   for any lawful purpose, including but not limited to analysis, research,   
# *   and reporting, without modification of the original Data or sharing any   
# *   modified versions of the Data.      
#
# *   Users of the Data must provide proper attribution to the original source   
# *   of the Data in any publication, research, or derivative works by including 
# *   the following attribution:  
# *
# *   Malone, B.P., de Gruijter, J.J., McBratney, A.B., Minasny, B., Brus, D.J. 
# *   (2011) Using Additional Criteria for Measuring the Quality of Predictions 
# *   and Their Uncertainties in a Digital Soil Mapping Framework. 
# *   Soil Science Society of America Journal, 75(3): 1032-1043.
# *                                                                            
# *  The Data is provided "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
# *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
# *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    
# *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR      
# *  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,      
# *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA OR THE USE OR OTHER   
# *  DEALINGS IN THE DATA                                                                       
# ******************************************************************************

## Point data
library(ithir)
data(HV100)
str(HV100)

## Necessary R packages
library(sf)
library(terra)

## Point data
library(ithir)
data(HV100)
str(HV100)

## Necessary R packages
library(sf)
library(terra)

## Spatial points
HV100 <- sf::st_as_sf(x = HV100,coords = c("x", "y"))

## Coordinate reference systems
sf::st_crs(HV100) <- 32756
st_crs(HV100)

## Coordinate transformation
HV100.ll <- st_transform(x = HV100, crs = 4326)

## Raster data
data(HV_dem)
str(HV_dem)

## convert data to raster object and CRS definition
r.DEM <- terra::rast(x = HV_dem, type = "xyz")
crs(r.DEM) <- "+init=epsg:32756"
r.DEM

## raster reprojection
p.r.DEM <- terra::project(x = r.DEM, y = "+init=epsg:4326", method = "bilinear")
p.r.DEM

###########################################################################################################3
## Interactive mapping

library(leaflet)
library(magrittr)
library(htmlwidgets)

## Basic map 
m1<- leaflet() %>%
  addMarkers(lng = 151.210558, lat = -33.852543,
             popup = "The view from here is amazing!") %>%
  addProviderTiles("Esri.WorldImagery")
m1

# save the object so that it can be embedded into website when called
#size appropriately
m1$height<- 500
m1$width<- 700
### Save the HTML widget
library(htmlwidgets)
saveWidget(m1, file="C:/rdev/site_source/_includes/htmlwidgets/m1.html")

## An aside: Pipe operators in R
## #Draw 100 random uniformly distributed numbers between 0 and 1
x <- runif(100)
sqrt(sum(range(x)))
## 
## ##..is equivalent to (using forward pipe operator)
name<- x %>% range %>% sum %>% sqrt
name

## # Basic map
## #without piping operator
addMarkers(addTiles(leaflet()), data = HV100.ll)

## 
## #with forward pipe operator
m2<- leaflet() %>%
  addTiles() %>%
  addMarkers(data = HV100.ll)

# save the object so that it can be embedded into website when called
#size appropriately
m2$height<- 500
m2$width<- 700
### Save the HTML widget
saveWidget(m2, file="C:/rdev/site_source/_includes/htmlwidgets/m2.html")

## Fiddling around with the markers
## Populate pop-ups
my_pops <- paste0(
  "<strong>Site: </strong>",
  HV100.ll$site,
  '<br>
  <strong> Organic Carbon (%): </strong>',
  HV100.ll$OC,
  '<br>
  <strong> soil pH: </strong>',
  HV100.ll$pH)
my_pops

##  Create interactive map
leaflet() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addMarkers(data = HV100.ll, popup = my_pops)

## Further marker enhancements
library(RColorBrewer)

## Colour ramp
pal1 <- colorQuantile("YlOrBr", domain = HV100.ll$OC)

## Create interactive map
leaflet() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addCircleMarkers(data = HV100.ll, color = ~pal1(OC), popup = my_pops) %>%
  addLegend("bottomright", pal = pal1, values = HV100.ll$OC,
            title = "Soil Organic Carbon (%) quantiles",
            opacity = 0.8)

## Rasters
## #Colour ramp
pal2 <- colorNumeric(
  brewer.pal(n = 9, name = "YlOrBr"),
  domain = values(p.r.DEM),
  na.color = "transparent")

## #interactive map
m3<- leaflet() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addRasterImage(p.r.DEM, colors = pal2, opacity = 0.7) %>%
  addLegend("topright", opacity=0.8, pal = pal2, values = values(p.r.DEM),
            title = "Elevation")

# save the object so that it can be embedded into website when called
#size appropriately
m3$height<- 500
m3$width<- 700
### Save the HTML widget
saveWidget(m3, file="C:/rdev/site_source/_includes/htmlwidgets/m3.html")


## #layer switching
m4<- leaflet() %>%
  addTiles(group = "OSM (default)") %>%
  addProviderTiles("Esri.WorldImagery") %>%
  
  addCircleMarkers(data = HV100.ll, color = ~pal1(OC),
                   group = "points", popup = my_pops) %>%
  addRasterImage(p.r.DEM, colors = pal2,group = "raster",
                 opacity = 0.8) %>%
  addLayersControl(
    baseGroups = c("OSM (default)", "Imagery"),
    overlayGroups = c("points", "raster"))
m4

# save the object so that it can be embedded into website when called
#size appropriately
m4$height<- 500
m4$width<- 700
### Save the HTML widget
saveWidget(m4, file="C:/rdev/site_source/_includes/htmlwidgets/m4.html")

##END