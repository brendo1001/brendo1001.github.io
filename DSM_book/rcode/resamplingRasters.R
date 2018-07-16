## R for GIS

#Raster resampling and reprojection

library(raster);library(rgdal);library(sp)


## Raster resampling

#Nowley Grids
list.files("D:/usyd_dsm/data/reprojection",  pattern="tif$", full.names=FALSE)
files<- list.files("D:/usyd_dsm/data/reprojection",  pattern="tif$",full.names=T)
files

b.grid<- raster(files[3]) #base grid to be resampled too
b.grid
crs(b.grid)
plot(b.grid)

r.grid<- raster(files[2])
r.grid
crs(r.grid)
plot(r.grid)

#resample
rs.grid<- resample(r.grid, b.grid, method='bilinear')
rs.grid

r3<- stack(rs.grid, b.grid)

### Reprojection and resampling

#landsat raster
l.grid<- raster(files[1])
crs(l.grid)
l.grid
plot(l.grid)

#elevation raster
e.grid<- raster(files[3])
crs(e.grid)
e.grid
plot(e.grid)

#reproject landsat grid
pl.grid <- projectRaster(from =l.grid, to = e.grid ,method="ngb")
pl.grid
plot(pl.grid)


#reproject and resample (50m pixels)
newProj<- crs(e.grid)
pl.grid10 <- projectRaster(l.grid, crs=newProj,method="ngb", res=50)
pl.grid10


##reprojection and rasterisation of polygon data

#get polygon
poly.dat <- readOGR(dsn = "D:/usyd_dsm/data/reprojection/soilMap/Soils_Curlewis_GDA94.shp", "Soils_Curlewis_GDA94")

# Attribute table
head(poly.dat@data)
summary(poly.dat@data$CODE)
summary(as.factor(as.numeric(poly.dat@data$CODE))) # numeric factor

#Basic plot
plot(poly.dat) 
invisible(text(getSpPPolygonsLabptSlots(poly.dat), labels = as.character(poly.dat@data$CODE), cex = 0.75))

# coordinate reference system
crs(poly.dat)

## Reproject to new projection (newProj)
poly.dat.T <- spTransform(poly.dat, CRSobj= newProj) 
class(poly.dat.T)

#plot
plot(pl.grid)
plot(poly.dat.T, add=T)
invisible(text(getSpPPolygonsLabptSlots(poly.dat.T), labels = as.character(poly.dat.T@data$CODE), cex = 1.2))


#rasterise polygon
r2 <- rasterize(poly.dat.T, pl.grid, field="CODE")

#plot rasterised polygon
r2 <- as.factor(r2)
rat <- levels(r2)[[1]] 

# Match raster levels to polygon code
m1<- c(as.matrix(levels(r2)[[1]]))
m2<- levels(poly.dat@data$CODE)[m1]
rat[["code"]] <- c(m2)
levels(r2) <- rat

# plot
levelplot(r2, xlab = "", ylab = "")





