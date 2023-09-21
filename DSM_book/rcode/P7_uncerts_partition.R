# ******************************************************************************
# *                                                                            
# *                           [Quantification of uncertainty]                                
# *                                                                            
# *  Description:       
##  Data partitioning and cross validation approach
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
library(ithir);library(MASS)
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
set.seed(1000)
training <- sample(nrow(DSM_data), 0.7 * nrow(DSM_data))
DSM_data_cal <- DSM_data[training, ] # calibration
DSM_data_val <- DSM_data[-training, ] # validation
nrow(DSM_data_cal)
nrow(DSM_data_val)


#Cubist model
names(DSM_data)
hv.cub.Exp <- cubist(x = DSM_data_cal[, c(5,11,13,15)], 
                     y = DSM_data_cal$pH60_100cm, 
                     cubistControl(unbiased = TRUE,rules = 10, 
                                   extrapolation = 5, sample = 0, 
                                   label = "outcome"), committees = 1)
summary(hv.cub.Exp)
# 2 rules

# append rule specification to data
DSM_data_cal$rule_spec<- NA
DSM_data_cal$rule_spec[which(DSM_data_cal$MRVBF > 0.004846)]<- 1
DSM_data_cal$rule_spec[which(DSM_data_cal$MRVBF <= 0.004846)]<- 2


## goodness of fit (calibration)
goof(observed= DSM_data_cal$pH60_100cm , predicted= predict(hv.cub.Exp, newdata = DSM_data_cal))

## Model residuals
DSM_data_cal$residual<- DSM_data_cal$pH60_100cm -  predict(hv.cub.Exp, newdata = DSM_data_cal)

# distribution of residuals in each rule set
hist(DSM_data_cal$residual[DSM_data_cal$rule_spec == 1], main = "Residuals ruleset 1")
hist(DSM_data_cal$residual[DSM_data_cal$rule_spec == 2], main = "Residuals ruleset 2")

# Quantiles of residual distribution within each ruleset
#Rule 1
r1.q<- quantile(DSM_data_cal$residual[DSM_data_cal$rule_spec == 1], 
                probs = c(0.005, 0.995,0.0125, 0.9875,0.025,0.975,0.05,0.95,0.1,0.9,0.2,0.8,0.3,0.7,0.4,0.6,0.45,0.55,0.475,0.525), 
                na.rm = FALSE,names = T, type = 7) 
r1.q

#Rule 2
r2.q<- quantile(DSM_data_cal$residual[DSM_data_cal$rule_spec == 2], 
                probs = c(0.005, 0.995,0.0125, 0.9875,0.025,0.975,0.05,0.95,0.1,0.9,0.2,0.8,0.3,0.7,0.4,0.6,0.45,0.55,0.475,0.525), 
                na.rm = FALSE,names = T, type = 7) 
r2.q

## MAPPING
map.cubist <- terra::predict(object = hv.sub.rasters, model = hv.cub.Exp)
msk <- terra::ifel(is.na(hv.sub.rasters[[1]]), NA, 1)
map.cubist<- terra::mask(map.cubist, msk, inverse = F)
plot(map.cubist)

# map the rule set distribution
names(hv.sub.rasters)
mapped.ruleset<- ifel(hv.sub.rasters[["MRVBF"]] > 0.004846 , 1, 2)
plot(mapped.ruleset, main = "rule set distribution", col = c("#f46d43", "#66c2a5"))

# upper and lower prediction intervals
# upper
map.cubist.upl<- terra::ifel(mapped.ruleset == 1, map.cubist + r1.q[8], map.cubist + r2.q[8])

# lower
map.cubist.lpl<- terra::ifel(mapped.ruleset == 1, map.cubist + r1.q[7], map.cubist + r2.q[7])

#Prediction interval range
map.cubist.pir<- map.cubist.upl - map.cubist.lpl

## PLOTTING
# color ramp
phCramp<- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598",
        "#abdda4", "#66c2a5" , "#3288bd","#5e4fa2","#542788", "#2d004b" )
brk <- c(2:14)
par(mfrow=c(2,2))
plot(map.cubist.lpl, main= "90% Lower prediction limit", breaks=brk, col=phCramp)
plot(map.cubist, main= "Prediction",breaks=brk, col=phCramp)
plot(map.cubist.upl, main= "90% Upper prediction limit",breaks=brk, col=phCramp)
plot(map.cubist.pir, main= "Prediction limit range", col = terrain.colors( length(seq(0, 6.5, by = 1))-1),
      axes = FALSE, breaks= seq(0, 6.5, by = 1))


## Model evaluation with out-of-bag cases
#Cubist model prediction 
DSM_data_val$model_pred<- predict(hv.cub.Exp, newdata = DSM_data_val)

# Evaluation
goof(observed = DSM_data_val$pH60_100cm, predicted = DSM_data_val$model_pred) 

# append rule specification to data
DSM_data_val$rule_spec<- NA
DSM_data_val$rule_spec[which(DSM_data_val$MRVBF > 0.004846)]<- 1
DSM_data_val$rule_spec[which(DSM_data_val$MRVBF <= 0.004846)]<- 2
summary(as.factor(DSM_data_val$rule_spec))

# upper and lower prediction limits
# upper
ulMat<- matrix(NA,nrow= nrow(DSM_data_val), ncol=length(r1.q))
for (i in seq(2,20,2)){
  ulMat[which(DSM_data_val$rule_spec == 1 ),i] <- r1.q[i]
  ulMat[which(DSM_data_val$rule_spec == 2 ),i] <- r2.q[i]}

# lower
for (i in seq(1,20,2)){
  ulMat[which(DSM_data_val$rule_spec == 1 ),i] <- r1.q[i]
  ulMat[which(DSM_data_val$rule_spec == 2 ),i] <- r2.q[i]}

#upper and lower prediction limits
ULpreds<- ulMat + DSM_data_val$model_pred
ULpreds<- as.data.frame(ULpreds)
names(ULpreds)<- names(r1.q)
DSM_data_val<- cbind(DSM_data_val, ULpreds)

#PICP
bMat<- matrix(NA,nrow= nrow(ULpreds), ncol= (ncol(ULpreds)/2))
cnt<- 1
for (i in seq(1,20,2)){
  bMat[,cnt] <- as.numeric(DSM_data_val$pH60_100cm <= ULpreds[,i+1] & DSM_data_val$pH60_100cm >= ULpreds[,i])
cnt<- cnt+1} 

colSums(bMat)/ nrow(bMat)

par(mfrow=c(1,1))
cs<- c(99,97.5,95,90,80,60,40,20,10,5)
plot(cs,((colSums(bMat)/ nrow(bMat))*100), ylab = "PICP", xlab = "confidence level")
# draw 1:1 line
abline(a=0, b = 1, col = "red")

# PICP by rule set for 90% confidence
# rule 1
sum(DSM_data_val$pH60_100cm[DSM_data_val$rule_spec == 1] <= DSM_data_val$`95%`[DSM_data_val$rule_spec == 1] & 
      DSM_data_val$pH60_100cm[DSM_data_val$rule_spec == 1] >= DSM_data_val$`5%`[DSM_data_val$rule_spec == 1])/
  nrow(DSM_data_val[DSM_data_val$rule_spec == 1,])

# rule 2
sum(DSM_data_val$pH60_100cm[DSM_data_val$rule_spec == 2] <= DSM_data_val$`95%`[DSM_data_val$rule_spec == 2] & 
      DSM_data_val$pH60_100cm[DSM_data_val$rule_spec == 2] >= DSM_data_val$`5%`[DSM_data_val$rule_spec == 2])/
  nrow(DSM_data_val[DSM_data_val$rule_spec == 2,])

## Prediction interval range
quantile(ULpreds[,8] - ULpreds[,7])


## END

