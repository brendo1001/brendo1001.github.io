##Using digital soil mapping to update, harmonize and disaggregate legacy soil maps.
## running dsmart

#install rdsmart
library(devtools)
install_bitbucket("brendo1001/dsmart/rPackage/dsmart/pkg")
library(rdsmart)

library(sp)
library(raster)
library(rasterVis)

#Polygons
data("dalrymple_polygons")
class(dalrymple_polygons)
summary(dalrymple_polygons$MAP_CODE)

## Plot polygons
plot(dalrymple_polygons)
invisible(text(getSpPPolygonsLabptSlots(dalrymple_polygons), labels=as.character(dalrymple_polygons$MAP_CODE), cex=1))

#Map unit compositions
data("dalrymple_composition")
head(dalrymple_composition)

#covariates
data("dalrymple_covariates")
class(dalrymple_covariates)
nlayers(dalrymple_covariates)
res(dalrymple_covariates)

#run dsmart
library(parallel)
# Run disaggregate without adding observations
test.dsmart<- rdsmart::disaggregate(covariates = dalrymple_covariates, 
             polygons = dalrymple_polygons, 
             composition = dalrymple_composition,
             rate = 15, reals = 10, cpus = 3)




#run dsmart summarise
#run function getting most probable and creating probability rasters using 4 compute cores.
# Load datasets
data(dalrymple_lookup)
data(dalrymple_realisations)


# Summarise
sum1<- summarise(realisations = dalrymple_realisations, dalrymple_lookup, nprob = 5, cpus = 2)



## PLOTTING
#plot most probable soil class
ml.map<- raster("C:/Users/bmalone/Documents/output/mostprobable/mostprob_01_class.tif")
ml.map
ml.map <- as.factor(ml.map)
rat <- levels(ml.map)[[1]]
rat[["class"]] <- c("BL","BU","BW","CE","CG","CK","CO","CP","DA","DO","EW","FL","FR","GA","GR","HG","PA","PI","RA","SC")
levels(ml.map) <- rat
 
#Randomly selected HEX colors
area_colors <- c("#9a10a8", "#cf68a0", "#e7cc15", "#4f043a", "#1129a3", "#a2d0a7", "#7b0687", "#3e28d1", "#2c8c04", "#d39014", "#66a5ed", "#978279", "#db6f1f", "#4070fc", "#fde864", "#acdb0a", "#d95a28", "#94561f", "#162972", "#8342e1")
levelplot(ml.map, col.regions=area_colors, xlab="", ylab="", main="Most probable soil class")

#Confusion Index
CI.map<- raster("C:/Users/bmalone/Documents/output/mostprobable/confusion.tif")
plot(CI.map)


###END
