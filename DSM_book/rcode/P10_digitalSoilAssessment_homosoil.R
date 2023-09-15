## Digital soil assessment: Homosoil


## HOMOSOIL FUNCTION
homosoil <- function (grid_data,recipient.lon,recipient.lat) {
# homosoil
# input: grid_data: global gridded data (05 x 0.5 degree grid)
# recipient.lon & lat: longitude & latitude of the recipient point
# Lithology code: 
# (3) non- or semi-consolidated sediments, 
# (4) mixed consolidated sediments, 
# (5) silic-clastic sediments
# (6) acid volcanic rocks
# (7) basic volcanic rocks
# (8) complex of metamorphic and igneous rocks
# (9) complex lithology.
gower <- function(c1, c2, r) 1-(abs(c1-c2)/r)        # Gower's similarity function


grid.lon <-grid_data[,1]
grid.lat <-grid_data[,2]
grid.climate <-grid_data[,3:54]  # climate data
grid.lith <-grid_data[,58] # lithology
grid.topo <-grid_data[,55:57] # topography
world.grid<- data.frame(grid_data[, c("X", "Y")], fid = seq(1, nrow(grid_data), 1), homologue = 0, homoclim=0, homolith=0, homotop=0) #grid output
 
# find the closest recipient point
dist=sqrt((recipient.lat-grid.lat)^2+(recipient.lon-grid.lon)^2)
imin= which.min(dist)
ndata=dim(grid.climate)[1]
ncol=dim(grid.climate)[2]

#climate, lithology and topography for recipient site
recipient.climate <- grid.climate[imin,]
recipient.lith <- grid.lith[imin]
recipient.topo <- grid.topo[imin,]



# homoclime
rv<-apply(grid.climate, 2, range)    # range of climate variables
rr<-rv[2,]-rv[1,]

# calculate similarity to all variables in the grid
S <- (mapply(gower, c1=grid.climate, c2=recipient.climate, r=rr))   

Sr<-apply(S, 1, mean)    # take the average
iclim=which(Sr >= quantile(Sr,0.85), arr.ind=TRUE)    # row index for homoclime with top 15% similarity.
hclim.lith <- grid.lith[iclim]
hclim.topo <- grid.topo[iclim,]

world.grid$homologue[iclim]<- 1  #append homoclime info to grid  
world.grid$homoclim[iclim]<- 1  #append homoclime info to grid  
#plot(rast(x = world.grid[,c(1,2,4)], type = "xyz"))

                            

# homolith
# find within homoclime, areas with homolith
ilith=which(grid.lith == recipient.lith, arr.ind=TRUE)  #within grid

clim.match<- which(world.grid$homologue == 1)
climlith.match<- clim.match[clim.match %in% ilith]
world.grid$homologue[climlith.match]<- 2  
world.grid$homolith[climlith.match]<- 1  
#plot(rast(x = world.grid[,c(1,2,4)], type = "xyz"))


# homotop
rv<-apply(grid.topo, 2, range)    # range of topographic variables
rt<-rv[2,]-rv[1,]

# calculate similarity of topographic variables
Sa <- (mapply(gower, c1=grid.topo, c2=recipient.topo, r=rt))   
St<-apply(Sa, 1, mean)    # take the average

itopo=which(St >= quantile(St,0.85), arr.ind=TRUE)    # row index for homotop
top.match<- which(world.grid$homologue == 2)
lithtop.match<- top.match[top.match %in% itopo]
world.grid$homologue[lithtop.match]<- 3  
world.grid$homotop[lithtop.match]<- 1  
#plot(rast(x = world.grid[,c(1,2,4)], type = "xyz"))

#homologue raster object
r1<- terra::rast(x = world.grid[,c(1,2,4)], type = "xyz")
r1 <- as.factor(r1)
rat <- levels(r1)[[1]]
rat[["homologue"]] <- c("", "homocline", "homolith", "homotop")
levels(r1) <- rat



# return outputs
retval <- list(r1, world.grid)
return(retval)}



## GET THE DATA
library(ithir);library(terra)
data(homosoil_globeDat)


## SITE LOCATION (Jakarta, Indonesia)
recipient.lat=-(6+10/60)
recipient.lon=106+ 49/60


## RUN FUNCTION
result<- homosoil(grid_data = homosoil_globeDat, recipient.lon = recipient.lon, recipient.lat = recipient.lat)

# get the map
map.out<- result[[1]]
crs(map.out) <- "+init=epsg:4326"
# plot
pt1 = sf::st_point(c(recipient.lon,recipient.lat))
as(st_geometry(pt1), Class="Spatial")
area_colors <- c("#EFEFEF", "#666666", "#FFDAD4", "#FF0000")
t1<- rasterVis::levelplot(map.out, col.regions = area_colors, xlab = "", ylab = "" ) 
t1 

## END
