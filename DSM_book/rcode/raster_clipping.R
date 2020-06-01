## Raster clipping with a polygon 

## libraries
library(raster);library(sp);library(rgdal)


## rasters
files<- list.files("/home/brendo1001/Downloads/reproj/",  pattern="tif$",full.names=T)
files

# RASTER 1: remote sensing data
rs.raster<- raster(files[1])
rs.raster

# RASTER 2: digital elevation model
elev.raster<- raster(files[2])
elev.raster


# polygon
poly.clip<- readOGR("/home/brendo1001/mystuff/devs/site_source/DSM_book/data/clipping/clipper_polygon.shp")


# CRS of data
crs(rs.raster)
crs(elev.raster)
crs(poly.clip)


# Basic plot
plot(rs.raster)
plot(poly.clip,add=T)


# clip
# crop the rs.raster to extent of polygon
cr <- crop(rs.raster, extent(poly.clip), snap="out")     #crop rasters to extent of boundary               
plot(cr)
plot(poly.clip, add=T)

fr <- rasterize(x = poly.clip, y = cr)   #rasterise the polygon 

# clip using mask
cr.clip <- mask(x=cr, mask=fr) #use the mask 
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
reproj.rs.raster<- projectRaster(from = cr.clip, to = elev.raster, method = "bilinear")
reproj.rs.raster


# stack rasters
stack.raster<- stack(reproj.rs.raster,elev.raster)
plot(stack.raster)

# clip both rasters simoultaneously
# reproject the polygon first
rp.poly.clip<- spTransform(x = poly.clip, CRSobj = crs(stack.raster))
rp.poly.clip

# clip
# crop the rs.raster to extent of polygon
cr <- crop(stack.raster, extent(rp.poly.clip), snap="out")     #crop rasters to extent of boundary               
fr <- rasterize(x = rp.poly.clip, y = cr)   #rasterise the polygon 
# clip using mask
cr.clip <- mask(x=cr, mask=fr) #use the mask 
cr.clip
par(mfrow=c(2,1))
plot(cr.clip[[1]], main= "RS data")
plot(cr.clip[[2]], main= "DEM")

plot(poly.clip, add=T)