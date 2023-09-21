# ******************************************************************************
# *                                                                            
# *                           [Quantification of uncertainty]                                
# *                                                                            
# *  Description:       
##  Some methods for the quantification of prediction uncertainties for digital soil mapping: 
##  Universal kriging prediction variance.
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


# load libraries
library(ithir)
library(sf)
library(terra)
library(gstat)


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

## Linear regression model
#Full model
lm1<- lm(pH60_100cm ~ Terrain_Ruggedness_Index + AACN + Landsat_Band1 + Elevation + Hillshading + Light_insolation + Mid_Slope_Positon + MRVBF + NDVI + TWI + Slope, data = DSM_data_cal   )

#Parsimous model
lm2<- step(lm1, direction = "both", trace = 0)
as.formula(lm2)
summary(lm2)

## Universal kriging model
names(DSM_data_cal)[3:4]<- c("x", "y")

# calculate empirical variogram
vgm1 <- variogram(pH60_100cm ~ Terrain_Ruggedness_Index + AACN + Landsat_Band1 + 
                    Elevation + Hillshading + Light_insolation + Mid_Slope_Positon + 
                    MRVBF + NDVI + TWI + Slope, ~x+y, data = DSM_data_cal, width = 200, cutoff = 3000)

# initialise variogram model parameters
mod <- vgm(psill = var(DSM_data_cal$pH60_100cm), "Sph", range = 3000, nugget = 0)

# fit model
model_1 <- fit.variogram(vgm1, mod)
model_1
plot(vgm1, model = model_1)

# Universal kriging model object
gUK <- gstat(NULL, "hunterpH_UK", pH60_100cm ~ Terrain_Ruggedness_Index + AACN + Landsat_Band1 + 
               Elevation + Hillshading + Light_insolation + Mid_Slope_Positon + 
               MRVBF + NDVI + TWI + Slope, data = DSM_data_cal, locations = ~x+y, model=model_1)
gUK

## Mapping
UK.P.maps <- terra::interpolate(object = hv.sub.rasters, model = gUK, xyOnly = FALSE)
plot(UK.P.maps)

#standard deviation
f2 <- function(x) (sqrt(x))
UK.stdev.map <- terra::app(x = UK.P.maps[[2]], fun=f2)
plot(UK.stdev.map)

#Z level
zlev<- qnorm(0.95)
f2 <- function(x) (x * zlev)
UK.mult.map <- terra::app(x = UK.stdev.map, fun=f2)
 
#Add and subtract mult from prediction
#upper PL
UK.upper.map <- UK.P.maps[[1]] + UK.mult.map

#lower PL
UK.lower.map <- UK.P.maps[[1]] - UK.mult.map

# prediction range
UK.piRange.map <- UK.upper.map - UK.lower.map
  
  
# color ramp
phCramp<- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598",
        "#abdda4", "#66c2a5" , "#3288bd","#5e4fa2","#542788", "#2d004b" )
brk <- c(2:14)
#plotting
par(mfrow=c(2,2))
plot(UK.lower.map, main= "90% Lower prediction limit", breaks=brk, col=phCramp)
plot(UK.P.maps[[1]], main= "Prediction",breaks=brk, col=phCramp)
plot(UK.upper.map, main= "90% Upper prediction limit",breaks=brk, col=phCramp)
plot(UK.piRange.map, main= "Prediction limit range", col = terrain.colors( length(seq(0, 6.5, by = 1))-1),
     axes = FALSE, breaks= seq(0, 6.5, by = 1) )


## Model evaluation
#Prediction
names(DSM_data_val)[3:4]<- c("x", "y")
UK.preds.V <- krige(pH60_100cm ~ Terrain_Ruggedness_Index + AACN + Landsat_Band1 + 
                      Elevation + Hillshading + Light_insolation + Mid_Slope_Positon + 
                      MRVBF + NDVI + TWI + Slope,data = DSM_data_cal, locations = ~x+y, model=model_1, newdata= DSM_data_val)
  
UK.preds.V$stdev<- sqrt(UK.preds.V$var1.var)
str(UK.preds.V)

# confidence levels
qp<- qnorm(c(0.995,0.9875,0.975,0.95,0.9,0.8,0.7,0.6,0.55,0.525)) 


# z factor multiplication
vMat<- matrix(NA,nrow= nrow(UK.preds.V), ncol= length(qp))
for (i in 1:length(qp)){
vMat[,i] <- UK.preds.V$stdev * qp[i]}

#upper
uMat<- matrix(NA,nrow= nrow(UK.preds.V), ncol= length(qp))
for (i in 1:length(qp)){
  uMat[,i] <- UK.preds.V$var1.pred + vMat[,i]}

#lower
lMat<- matrix(NA,nrow= nrow(UK.preds.V), ncol= length(qp))
for (i in 1:length(qp)){
  lMat[,i] <- UK.preds.V$var1.pred - vMat[,i]}

## PICP
bMat<- matrix(NA,nrow= nrow(UK.preds.V), ncol= length(qp))
for (i in 1:ncol(bMat)){
  bMat[,i] <- as.numeric(DSM_data_val$pH60_100cm <= uMat[,i] & DSM_data_val$pH60_100cm >= lMat[,i])} 

colSums(bMat)/ nrow(bMat)


#make plot
par(mfrow=c(1,1))
cs<- c(99,97.5,95,90,80,60,40,20,10,5)
plot(cs,((colSums(bMat)/ nrow(bMat))*100), ylab = "PICP", xlab = "confidence level")
# draw 1:1 line
abline(a=0, b = 1, col = "red")

## Goodness of fit: validation
goof(observed = DSM_data_val$pH60_100cm , predicted = UK.preds.V$var1.pred)

## prediction range
cs<- c(99,97.5,95,90,80,60,40,20,10,5) # confidence level
colnames(lMat)<- cs
colnames(uMat)<- cs
quantile(uMat[,"90"] - lMat[,"90"])

## END
