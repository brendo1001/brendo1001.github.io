## Raster clipping with a polygon 

## libraries
library(terra);library(sf)


## rasters
files<- list.files("/home/brendo1001/mystuff/muddles/reproj/",  pattern="tif$",full.names=T)
files

# RASTER 1: remote sensing data
rs.raster<- terra::rast(files[1])
rs.raster

# RASTER 2: digital elevation model
elev.raster<- terra::rast(files[2])
elev.raster


# polygon
poly.clip<- terra::vect("/home/brendo1001/mystuff/muddles/clipping/clipper_polygon.shp")


# CRS of data
crs(rs.raster,describe = T, proj = T)
crs(elev.raster, describe = T, proj = T)
crs(poly.clip, describe = T, proj = T)


# Basic plot
plot(rs.raster)
plot(poly.clip,add=T)


# clip
# crop the rs.raster to extent of polygon
cr <- terra::crop(rs.raster, terra::ext(poly.clip), snap="out")     #crop rasters to extent of boundary               
plot(cr)
plot(poly.clip, add=T)

fr <- terra::rasterize(x = poly.clip, y = cr)   #rasterise the polygon 

# clip using mask
cr.clip <- terra::mask(x=cr, mask=fr) #use the mask 
plot(cr.clip)
plot(poly.clip, add=T)

#plot all 3 
par(mfrow=c(2,2))
# plot 1
plot(rs.raster,main= "RS data all")
plot(poly.clip,add=T)

# plot 2
plot(cr,main = "RS data poly extent" )
plot(poly.clip, add=T)

# plot 3
plot(cr.clip, main = "RS data clipped")
plot(poly.clip, add=T)



## reproject clipped rs.raster to same as elev.raster
reproj.rs.raster<- terra::project(x = cr.clip, y = elev.raster, method = "bilinear")
reproj.rs.raster


# stack rasters
stack.raster<- c(reproj.rs.raster,elev.raster)
plot(stack.raster)

# clip both rasters simultaneously
# reproject the polygon first
rp.poly.clip<- terra::project(x = poly.clip, y = crs(stack.raster))
rp.poly.clip

# clip
# crop the rs.raster to extent of polygon
cr <- terra::crop(stack.raster, terra::ext(rp.poly.clip), snap="out")     #crop rasters to extent of boundary               
fr <- terra::rasterize(x = rp.poly.clip, y = cr)   #rasterise the polygon 
# clip using mask
cr.clip <- terra::mask(x=cr, mask=fr) #use the mask 
cr.clip
par(mfrow=c(2,1))
plot(cr.clip[[1]], main= "RS data")
plot(rp.poly.clip, add=T)
plot(cr.clip[[2]], main= "DEM")
plot(rp.poly.clip, add=T)
