##
# ******************************************************************************
# *                                                                            
# *                           [The DSMART algo]                                
# *                                                                            
# *  Description:       
##  Using digital soil mapping to update, harmonize and disaggregate legacy soil maps.
##    
#
# * 
# *       
# *       
# *       
# *                                                                            
# *  Created By:                                                               
# *  Brendan Malone                                                
# *                                                                            
# *  Last Modified:                                                            
# *  2023-09-20             
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
# *   1. Malone, B. P., Minasny, B. & McBratney, A. B. (2017). 
# *   Using R for Digital Soil Mapping, Cham, Switzerland: Springer International Publishing. 
# *   https://doi.org/10.1007/978-3-319-44327-0#
# *   
# *
# *  The Data is provided "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
# *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
# *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    
# *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR      
# *  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,      
# *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA OR THE USE OR OTHER   
# *  DEALINGS IN THE DATA                                                                       
# ******************************************************************************



# libraries
#install rdsmart
#library(devtools)
#devtools::install_bitbucket("brendo1001/dsmart")
library(rdsmart)
library(sf);library(terra)
library(sp);library(raster)
# Note rdsmart is yet to migrate functionality to the sf and terra R packages, there the example currently runs using the now legacy sp and raster R packages.

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
raster::nlayers(dalrymple_covariates)
res(dalrymple_covariates)

#run dsmart
# Run disaggregate without adding observations
test.dsmart<- rdsmart::disaggregate(covariates = dalrymple_covariates, 
             polygons = dalrymple_polygons, 
             composition = dalrymple_composition,
             rate = 15, reals = 5, cpus = 1, 
             outputdir = "/home/brendo1001/tempfiles/dsmart/")
test.dsmart

#run dsmart summarise


# Summarise
in.dir<- "/home/brendo1001/tempfiles/dsmart/"

# locate the rasters
ras.files<- list.files(path = paste0(in.dir, "output/realisations/"), 
                       pattern = ".tif", full.names = T,recursive = F)
ras.files
test.rasters<- raster::stack(ras.files)
test.rasters

# read in lookup table
test.lookup<- read.csv(file = paste0(in.dir,"output/lookup.txt"))

# run summarise
sum1<- rdsmart::summarise(realisations = test.rasters, 
                          lookup = test.lookup , 
                          outputdir = in.dir,
                          nprob = 3, 
                          cpus = 1)

## confusion index
# find the probability rasters
in.dir<- "SOME_DIRECTORY"
prob.files<- list.files(path = paste0(in.dir, "output/probabilities/"), 
           pattern = ".tif", full.names = T, recursive = F)
# stack
prob.rasters<- raster::stack(prob.files)
conf.ind<- rdsmart::confusion_index(prob.rasters, cpus = 1)
plot(conf.ind)

#plot most probable soil class
ml.map<- terra::rast(paste0(in.dir, "output/mostprobable/mostprob_01_class.tif"))
ml.map
ml.map <- as.factor(ml.map)

# some classes have been dropped from map 
levels(ml.map)[[1]][,1]
rms<- which(test.lookup[,2] %in% levels(ml.map)[[1]][,1])
new.lookup<- test.lookup[rms,]
levels(ml.map) = data.frame(value = new.lookup[,2], desc = new.lookup[,1])

#Randomly selected HEX colors
area_colors <- c("#9a10a8", "#cf68a0", "#e7cc15", "#4f043a", "#1129a3", "#a2d0a7", "#7b0687", "#3e28d1", "#2c8c04", "#d39014", "#66a5ed", "#978279", "#db6f1f", "#4070fc", "#fde864", "#acdb0a", "#d95a28", "#94561f", "#162972", "#8342e1")

# plot
terra::plot(ml.map, col = area_colors,
            plg=list(legend = new.lookup[,1], cex=0.8))


###END
