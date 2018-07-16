### Getting Spatial in R
# Some examples of using R for some basic GIS operations


## Point data
library(ithir)
data(HV100)
str(HV100)


## Necessary R packages
library(sp)
library(raster)
library(rgdal)

## Spatial points
coordinates(HV100) <- ~x + y
str(HV100)

## Plot points
 spplot(HV100, "OC", scales = list(draw = T), cuts = 5,
        col.regions = bpy.colors (cutoff.tails = 0.1, alpha = 1), cex = 1)

## Coordinate reference systems
proj4string(HV100) <- CRS("+init=epsg:32756")
HV100@proj4string

## Write point data to shapefile
 writeOGR(HV100, ".", "HV_dat_shape", "ESRI Shapefile")


## Coordinate transformation
HV100.ll <- spTransform(HV100, CRS("+init=epsg:4326"))

# Export file to KML
writeOGR(HV100.ll, "HV100.kml", "ID", "KML")


## Read shapefile into memory
imp.HV.dat <- readOGR(".", "HV_dat_shape")
imp.HV.dat@proj4string



## Ratser data
library(ithir)
data(HV_dem)
str(HV_dem)


## convert data to raster object and CRS definition
r.DEM <- rasterFromXYZ(HV_dem)
proj4string(r.DEM) <- CRS("+init=epsg:32756")

## Ratser plotting and point overlay
plot(r.DEM)
points(HV100, pch = 20)

## Write raster to disk
writeRaster(r.DEM, filename = "HV_dem100.asc", format = "ascii", overwrite = TRUE)


## raster reprojection
p.r.DEM <- projectRaster(r.DEM, crs = "+init=epsg:4326", method = "bilinear")
KML(p.r.DEM, "HV_DEM.kml", col = rev(terrain.colors(255)), overwrite = TRUE)


## Read raster from file
read.grid <- readGDAL("HV_dem100.asc")

## convert to raster object
grid.dem <- raster(read.grid)
grid.dem

## Raster object remains on disk not R memory
grid.dem <- raster(paste(paste(getwd(),"/",sep=""),"HV_dem100.asc", sep=""))
grid.dem
plot(grid.dem)

###########################################################################################################3
## Interactive mapping

library(leaflet)
library(magrittr)

## Basic map 
 leaflet() %>%
   addMarkers(lng = 151.210558, lat = -33.852543,
     popup = "The view from here is amazing!") %>%
   addProviderTiles("Esri.WorldImagery")

## An aside: Pipe operators in R
## #Draw 100 random uniformly distributed numbers between 0 and 1
x <- runif(100)
sqrt(sum(range(x)))
## 
## ##..is equivalent to (using forward pipe operator)
name<- x %>% range %>% sum %>% sqrt


## # Basic map
## #without piping operator
addMarkers(addTiles(leaflet()), data = HV100.ll)
## 
## #with forward pipe operator
leaflet() %>%
addTiles() %>%
addMarkers(data = HV100.ll)

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
 leaflet() %>%
   addProviderTiles("Esri.WorldImagery") %>%
   addRasterImage(p.r.DEM, colors = pal2, opacity = 0.7) %>%
   addLegend("topright", opacity=0.8, pal = pal2, values = values(p.r.DEM),
             title = "Elevation")


## #layer switching
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
 
 ##END

