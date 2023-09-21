# ******************************************************************************
# *                                                                            
# *                           [Quantification of uncertainty]                                
# *                                                                            
# *  Description:       
##  Bootstapping
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

# Libraries
library(ithir)
library(sf)
library(terra)
library(Cubist)

# point data
data(HV_subsoilpH)

# Start afresh round pH data to 2 decimal places
HV_subsoilpH$pH60_100cm <- round(HV_subsoilpH$pH60_100cm, 2)

# remove already intersected data
HV_subsoilpH <- HV_subsoilpH[, 1:3]

# add an id column
HV_subsoilpH$id <- seq(1, nrow(HV_subsoilpH), by = 1)

# re-arrange order of columns
HV_subsoilpH <- HV_subsoilpH[, c(4, 1, 2, 3)]

# Change names of coordinate columns
names(HV_subsoilpH)[2:3] <- c("x", "y")
# save a copy of coordinates
HV_subsoilpH$x2 <- HV_subsoilpH$x
HV_subsoilpH$y2 <- HV_subsoilpH$y

# convert data to sf object
HV_subsoilpH <- sf::st_as_sf(x = HV_subsoilpH, coords = c("x", "y"))

# grids (covariate rasters from ithir package)
hv.sub.rasters <- list.files(path = system.file("extdata/", package = "ithir"), pattern = "hunterCovariates_sub", full.names = TRUE)

# read them into R as SpatRaster objects
hv.sub.rasters <- terra::rast(hv.sub.rasters)

# extract covariate data
DSM_data <- terra::extract(x = hv.sub.rasters, y = HV_subsoilpH, bind = T, method = "simple")
DSM_data <- as.data.frame(DSM_data)

# check for NA values
which(!complete.cases(DSM_data))
DSM_data<- DSM_data[complete.cases(DSM_data),]

#subset data for modeling
set.seed(123)
training <- sample(nrow(DSM_data), 0.7 * nrow(DSM_data))
DSM_data_cal <- DSM_data[training, ] # calibration
DSM_data_val <- DSM_data[-training, ] # validation
nrow(DSM_data_cal)
nrow(DSM_data_val)

#Number of bootstraps
nbag<-50

#Fit cubist models for each bootstrap
for ( i in 1:nbag){
  # sample with replacement
  sample.wr <- sample.int(n = nrow(DSM_data_cal), size = nrow(DSM_data_cal), replace = TRUE)
  # unique cases
  sample.wr<- unique(sample.wr)
  # fit model
  fit_cubist <- cubist(x = DSM_data_cal[sample.wr, 5:15], 
                       y = DSM_data_cal$pH60_100cm[sample.wr], 
                       cubistControl(rules = 5, extrapolation = 5), committees = 1)
  
  ### Note you will likely have different file path names ###
  modelFile<- paste0("/home/brendo1001/tempfiles/bootstrap/models/bootMod_",i,".rds")
  saveRDS(object = fit_cubist, file = modelFile)}

# list all model files in directory
### Note you will likely have different file path names ###
c.models<- list.files(path = "/home/brendo1001/tempfiles/bootstrap/models/", 
                      pattern="\\.rds$", full.names=TRUE)
head(c.models)


# model evaluation
# calibration data
cubiMat.cal<- matrix(NA, nrow= nbag, ncol=5)
for (i in 1:nbag){
fit_cubist<- readRDS(c.models[i])
cubiMat.cal[i,]<- as.matrix(goof(observed= DSM_data_cal$pH60_100cm , predicted= predict(fit_cubist, newdata = DSM_data_cal)))}
cubiMat.cal<- as.data.frame(cubiMat.cal)
names(cubiMat.cal)<- c("R2", "concordance", "MSE", "RMSE", "bias")
colMeans(cubiMat.cal)
hist(cubiMat.cal$concordance)

# out-of-bag data
cubiMat.valpreds<- matrix(NA, ncol= nbag, nrow= nrow(DSM_data_val))
cubiMat.val<- matrix(NA, nrow= nbag, ncol=5)
for (i in 1:nbag){
  fit_cubist<- readRDS(c.models[i])
  cubiMat.valpreds[,i]<- predict(fit_cubist, newdata = DSM_data_val)
  cubiMat.val[i,]<- as.matrix(goof(observed= DSM_data_val$pH60_100cm , predicted= predict(fit_cubist, newdata = DSM_data_val)))}

# mean predicted value
cubiMat.valpreds.MEAN<- rowMeans(cubiMat.valpreds)

cubiMat.val<- as.data.frame(cubiMat.val)
names(cubiMat.val)<- c("R2", "concordance", "MSE", "RMSE", "bias")
colMeans(cubiMat.val)
hist(cubiMat.val$concordance)

#Average validation MSE
avGMSE<- mean(cubiMat.val[,3])
avGMSE


## Mapping
## ### Note you will likely have different file path names ###
for (i in 1:nbag){
  fit_cubist<- readRDS(c.models[i])
  mapFile<-paste0("/home/brendo1001/tempfiles/bootstrap/map/bootMap_",i,".tif")
  terra::predict(object = hv.sub.rasters,model = fit_cubist,
               filename=mapFile,overwrite=T)}

## statistical measures of maps
## #Pathway to rasters
## ### Note you will likely have different file path names ###
map.files<- list.files(path = "/home/brendo1001/tempfiles/bootstrap/map/",  
                       pattern="bootMap", full.names=TRUE)
map.files 

#Raster stack all maps
pred.stack<- terra::rast(map.files)

# calculate mean
bootMap.mean<- terra::app(x = pred.stack, fun = mean)
# mask
msk <- terra::ifel(is.na(hv.sub.rasters[[1]]), NA, 1)
bootMap.mean<- terra::mask(bootMap.mean, msk, inverse = F)
plot(bootMap.mean)


# calculate variance
bootMap.var<- terra::app(x = pred.stack, fun = var)

# overall prediction variance (adding avGMSE)
bootMap.varF<- bootMap.var + avGMSE 

#Standard deviation
bootMap.sd<- sqrt(bootMap.varF) 

#standard error
bootMap.se<- bootMap.sd * qnorm(0.95)

#upper prediction limit
bootMap.upl<- bootMap.mean + bootMap.se
bootMap.upl<- terra::mask(bootMap.upl, msk, inverse = F)

#lower prediction limit
bootMap.lpl<- bootMap.mean - bootMap.se
bootMap.lpl<- terra::mask(bootMap.lpl, msk, inverse = F)

#prediction interval range
bootMap.pir<- bootMap.upl - bootMap.lpl
bootMap.pir<- terra::mask(bootMap.pir, msk, inverse = F)

##PLOTTING
phCramp<- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598",
             "#abdda4", "#66c2a5" , "#3288bd","#5e4fa2","#542788", "#2d004b" )
brk <- c(2:14)
par(mfrow=c(2,2))
plot(bootMap.lpl, main= "90% Lower prediction limit", breaks=brk, col=phCramp)
plot(bootMap.mean, main= "Prediction",breaks=brk, col=phCramp)
plot(bootMap.upl, main= "90% Upper prediction limit",breaks=brk, col=phCramp)
plot(bootMap.pir, main= "Prediction limit range",col = terrain.colors( length(seq(0, 6.5, by = 1))-1),
      axes = FALSE, breaks= seq(0, 6.5, by = 1) )


## out-of-bag model evaluation
colMeans(cubiMat.val)
hist(cubiMat.val$concordance)

# calculate prediction standard deviation 
# including systematic error
val.sd<- matrix(NA, ncol=1, nrow= nrow(cubiMat.valpreds))
for (i in 1:nrow(cubiMat.valpreds)){
val.sd[i,1]<- sqrt(var(cubiMat.valpreds[i,])+ avGMSE)}

# Percentiles of normal distribution
qp<- qnorm(c(0.995,0.9875,0.975,0.95,0.9,0.8,0.7,0.6,0.55,0.525)) 

# z factor multiplication (standard error) 
vMat<- matrix(NA,nrow= nrow(cubiMat.valpreds), ncol= length(qp))
for (i in 1:length(qp)){
  vMat[,i] <- val.sd * qp[i]}

# upper prediction limit
uMat<- matrix(NA,nrow= nrow(cubiMat.valpreds), ncol= length(qp))
for (i in 1:length(qp)){
  uMat[,i] <- cubiMat.valpreds.MEAN + vMat[,i]}

# lower prediction limit
lMat<- matrix(NA,nrow= nrow(cubiMat.valpreds), ncol= length(qp))
for (i in 1:length(qp)){
  lMat[,i] <- cubiMat.valpreds.MEAN - vMat[,i]}

## PICP
bMat<- matrix(NA,nrow= nrow(cubiMat.valpreds), ncol= length(qp))
for (i in 1:ncol(bMat)){
  bMat[,i] <- as.numeric(DSM_data_val$pH60_100cm <= uMat[,i] & DSM_data_val$pH60_100cm >= lMat[,i])} 

colSums(bMat)/ nrow(bMat)

#make plot
par(mfrow=c(1,1))
cs<- c(99,97.5,95,90,80,60,40,20,10,5)
plot(cs,((colSums(bMat)/ nrow(bMat))*100), ylab = "PICP", xlab = "confidence level")
# draw 1:1 line
abline(a=0, b = 1, col = "red")

## Prediction limit range 90% PI
cs<- c(99,97.5,95,90,80,60,40,20,10,5) # confidence level
colnames(lMat)<- cs
colnames(uMat)<- cs
quantile(uMat[,"90"] - lMat[,"90"])

# END



