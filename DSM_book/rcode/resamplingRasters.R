### Using R for Digital Soil Mapping
# Reprojections, resampling and rasterisation
# URL: http://smartdigiag.com/DSM_book/pages/r_gis/reprojs/
# Author: Brendan Malone
# Email: brendan.malone@csiro.au
# Date Created: 22.8.23
# Date Modified: 22.8.23


## load packages
library(terra);library(sf)


## Path to files. This will be different for you
files<- list.files("/home/brendo1001/mystuff/muddles/reproj/", pattern="tif$",full.names=T)
files

# RASTER 1: remote sensing data
rs.raster<- rast(files[1])
rs.raster

# RASTER 2: digital elevation model
elev.raster<- rast(files[2])
elev.raster

# RASTER 3: Very granular gamma radiometrics data
gamma.raster<- rast(files[3])
gamma.raster


# resample
rs.grid<- terra::resample(x = elev.raster, y = gamma.raster, method='bilinear')
rs.grid

# stack 
r3<- c(rs.grid, gamma.raster)
r3


#reproject remote sensing grid
pl.grid <- terra::project(x =rs.raster, y = elev.raster , method="near")

# stack
r4<- c(pl.grid, elev.raster)
r4


#reproject and resample (50m pixels)
pl.grid50 <- terra::project(x = rs.raster, y = crs(elev.raster), method="near", res=50)
pl.grid50


## Read in shapefile of soil mapping units [path will be different for you]
poly.dat <- st_read("/home/brendo1001/mystuff/muddles/reproj/soilMap/Soils_Curlewis_GDA94.shp")
poly.dat


## Explore the data
# Attribute table
head(poly.dat)

# soil type code and frequency
summary(poly.dat)
summary(as.factor(poly.dat$CODE)) # numeric factor

#Basic plot 
plot(poly.dat) 

# coordinate reference system
st_crs(poly.dat)


## Reproject to new projection (newProj)
newProj<- st_crs(pl.grid)
poly.dat.T <- st_transform(poly.dat, crs= newProj) 
poly.dat.T


## Plot raster and overlay with shape
plot(pl.grid)
plot(poly.dat.T["LANDSCAPE"], add = T, col = sf.colors(categorical = TRUE, alpha = 0.2))


## Rasterise polygon
# convert sf to vect
poly.dat.V<- terra::vect(poly.dat.T)

# rasterise
poly.raster <- terra::rasterize(x = poly.dat.V, y = pl.grid50, field="CODE")
names(poly.raster)<- "soil_map_CODE"

#stack
r5<- c(pl.grid50,poly.raster)
r5

