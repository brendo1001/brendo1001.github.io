
# ******************************************************************************
# *                                                                            
# *                           [Quantification of uncertainty]                                
# *                                                                            
# *  Description:       
##  Empirical uncertainty quantification through fuzzy clustering and cross validation
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
#may need to install the package
#install.packages("devtools") 
#library(devtools)
#install_bitbucket("brendo1001/fuzme/rPackage/fuzme")


library(ithir)
library(sf)
library(terra)
library(randomForest)
library(gstat)
library(fuzme)

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

## Model fitting
hv.RF.Exp <- randomForest(x = DSM_data_cal[,5:15], y = DSM_data_cal$pH60_100cm, 
                          data = DSM_data_cal , importance = TRUE, ntree = 1000)
# goodness of fit on calibration data
goof(observed = DSM_data_cal$pH60_100cm , predicted = predict(hv.RF.Exp, newdata = DSM_data_cal),plot.it=FALSE)

# calculate the residual
DSM_data_cal$residual<- DSM_data_cal$pH60_100cm -  predict(hv.RF.Exp, newdata = DSM_data_cal)

# calculate empirical variogram of residuals
names(DSM_data_cal)[3:4]<- c("x", "y")
vgm1 <- variogram(residual ~ 1, ~x+y, 
                  data = DSM_data_cal, width = 200, cutoff = 3000)

# initialise variogram model parameters
mod <- vgm(psill = var(DSM_data_cal$residual), "Sph", range = 3000, nugget = 0)

# fit variogram model
model_1 <- fit.variogram(vgm1, mod)
model_1
plot(vgm1, model = model_1)

# variogram object
gR <- gstat(NULL, "hunterpH_residual_RF", residual ~ 1, 
            data = DSM_data_cal, locations = ~x+y, model=model_1)



## LEAVE - ONE - OUT - CROSS - VALIDATION
# estimation of empirical model residuals
# Note: the following step could take a little time to compute.
# This data can be loaded to avoid the following step of LOCV
# Just get your file paths right
# looResidualdata
# DSM_data_cal<- read.csv(file="/home/brendo1001/mystuff/devs/site_source/DSM_book/data/uncerts/hunter_DSMDat.csv")
# End note

# placeholder for cv residuals
DSM_data_cal$looResiduals<- NA

for(i in 1:nrow(DSM_data_cal)){
  # subset model frame
  sub.frame<- DSM_data_cal[-i,]
  # fit model
  looRFPred<-randomForest(x = sub.frame[,5:15], y = sub.frame$pH60_100cm, 
                           importance = TRUE, ntree = 500)
   rf.preds<- predict(looRFPred, newdata = sub.frame[,5:15])
   sub.frame$locv_resid<- sub.frame$pH60_100cm - rf.preds
   #residual variogram
   vgm.locv <- variogram(locv_resid ~ 1, ~x+y, 
                     data = sub.frame, width = 200, cutoff = 3000)
   mod.locv <- vgm(psill = var(sub.frame$locv_resid), "Sph", range = 3000, nugget = 0)
   model.locv <- fit.variogram(vgm.locv, mod.locv)
   model.locv
   #interpolate residual
   int.resids<- krige(locv_resid ~ 1,locations= ~x+y, data = sub.frame, newdata= DSM_data_cal[i,] , model = model.locv, debug.level= 0)[1,3]
   looPred<-predict( object = looRFPred, newdata = DSM_data_cal[i,5:15])
   DSM_data_cal$looResiduals[i]<- DSM_data_cal$pH60_100cm[i] - (looPred+int.resids)
   print(nrow(DSM_data_cal)-i)}
 
## FUZZY KMEANS with EXTRAGRADES
# Computation of optimal alfa value used for FKM with extragrades
# Note: the following step could take a little time to compute.
# This data can be loaded to avoid the following step of FKM with extragrade
# Just get file paths right
#load("alfa.t.rda") [download link]
# End Note
 
data.t<-  DSM_data_cal[,5:15] # data to be clustered
nclass.t<- 4 # number of clusters
phi.t<- 1.2 # fuzzy exponent
distype.t<- 3 # 3 = Mahalanobis distance
Uereq.t<- 0.10 # average extragrade membership
  
#initial membership matrix
scatter.t<- 0.2    # scatter around initial membership
ndata.t<- dim(data.t)[1]
U.t<- fuzme::initmember(scatter = scatter.t,
                        nclass = nclass.t, 
                        ndata = ndata.t)
 
#run fuzzy objective function
alfa.t<- fuzme::fobjk(Uereq= Uereq.t,
                      nclass= nclass.t, 
                      data= data.t, 
                      U = U.t, 
                      phi= phi.t, 
                      distype= distype.t)
alfa.t

## FKM with extragrade
# Note: the following step could take a little time to compute.
# This data can be loaded to avoid the following step of FKM with extragrade
# Just get your file paths right
#readRDS(file = "fkme_example_out.rds") [download link]
# End Note

alfa.t<- 0.01136809
tester<- fkme(nclass = nclass.t, 
              data = data.t, 
              U = U.t, 
              phi = phi.t, 
              alfa= alfa.t, 
              maxiter =500, 
              distype = distype.t,
              toldif = 0.01, 
              verbose = 1)

## Fuzzy performance indices
fuzme::fvalidity(U = tester$membership[,1:4], 
                 dist = tester$distance, 
                 centroid = tester$centroid, 
                 nclass = 4 ,
                 phi = 1.2, 
                 W= tester$distNormMat )

## Confusion index
mean(confusion(nclass = 5 ,U = tester$membership))
# Note number of cluster is set to 5 to account for the
# Additional extragrade cluster.

## Assign class for each point
membs<- as.data.frame(tester$membership)
membs$class<- NA
for (i in 1:nrow(membs)){
  mbs2<- membs[i,1:ncol(tester$membership) ]
  #which is the maximum probability on this row
  membs$class[i]<- which(mbs2 == max(mbs2))[1]}

membs$class<- as.factor(membs$class)
summary(membs$class)

#combine
DSM_data_cal<- cbind(DSM_data_cal, membs$class)
names(DSM_data_cal)[ncol(DSM_data_cal)]<- "class"
levels(DSM_data_cal$class)

## QUANTILES OF RESIDUALS IN EACH CLASS FOR CLASS PREDICTION LIMITS
DSM_data_cal.split<- split(DSM_data_cal, DSM_data_cal$class)

# cluster lower prediction limits
quanMat1<- matrix(NA, ncol=10, nrow=length(DSM_data_cal.split))
for (i in 1:length(DSM_data_cal.split)){
  quanMat1[i,]<- quantile(DSM_data_cal.split[[i]][,"looResiduals"], probs = c(0.005,0.0125,0.025,0.05,0.1,0.2,0.3,0.4,0.45,0.475), na.rm = FALSE,names = F, type = 7)}
row.names(quanMat1)<- levels(DSM_data_cal$class) 
quanMat1[nrow(quanMat1),]<- quanMat1[nrow(quanMat1),]*2
quanMat1<- t(quanMat1)
row.names(quanMat1)<- c(99,97.5,95,90,80,60,40,20,10,5) #

# cluster upper prediction limits
quanMat2<- matrix(NA, ncol=10, nrow=length(DSM_data_cal.split))
for (i in 1:length(DSM_data_cal.split)){
  quanMat2[i,]<- quantile(DSM_data_cal.split[[i]][,"looResiduals"], probs = c(0.995,0.9875,0.975,0.95,0.9,0.8,0.7,0.6,0.55,0.525), na.rm = FALSE,names = F, type = 7)}
quanMat2[quanMat2<0] <- 0
row.names(quanMat2)<- levels(DSM_data_cal$class) 
quanMat2[nrow(quanMat2),]<- quanMat2[nrow(quanMat2),]*2
quanMat2<- t(quanMat2)
row.names(quanMat2)<- c(99,97.5,95,90,80,60,40,20,10,5) #


## Evaluation of predictions and uncertainties with out of bag data

# covariates of the out-of-bag data
vCovs<- DSM_data_val[,5:15]

# run fkme allocation function
fuzAll<- fuzme::fuzExall(data= vCovs,
                  phi= 1.2,
                  centroid= tester$centroid, 
                  distype= 3,
                  W= tester$distNormMat, 
                  alfa= tester$alfa)

#Get the memberships
fuz.me<- fuzAll$membership


#lower prediction limit
lPI.mat<- matrix(NA,nrow=nrow(fuz.me), ncol=10)
for (i in 1:nrow(lPI.mat)){
  for (j in 1:nrow(quanMat1)){
lPI.mat[i,j]<-  sum(fuz.me[i,1:ncol(fuz.me)]* quanMat1[j,])}}

#upper prediction limit
uPI.mat<- matrix(NA,nrow=nrow(fuz.me), ncol=10)
for (i in 1:nrow(uPI.mat)){
  for (j in 1:nrow(quanMat2)){
    uPI.mat[i,j]<-  sum(fuz.me[i,1:ncol(fuz.me)]* quanMat2[j,])}}

#Regression kriging predictions for out-of-bag data
names(DSM_data_val)[3:4]<- c("x", "y")
DSM_data_val$rf_preds<- predict(object = hv.RF.Exp, newdata = DSM_data_val[,5:15])
DSM_data_val$krig_res<- krige(residual ~ 1, data = DSM_data_cal, locations = ~x+y, 
                              model = model_1, newdata = DSM_data_val)[,3]
DSM_data_val$RK_preds<- DSM_data_val$rf_preds + DSM_data_val$krig_res 

# evaluation of model goodness of fit
goof(observed = DSM_data_val$pH60_100cm, predicted = DSM_data_val$RK_preds,plot.it = TRUE ) 

#Derive validation lower prediction limits
lPL.mat<- matrix(NA,nrow=nrow(fuz.me), ncol=10)
for (i in 1:ncol(lPL.mat)){
  lPL.mat[,i]<- DSM_data_val$RK_preds + lPI.mat[,i]}

#Derive validation upper prediction limits
uPL.mat<- matrix(NA,nrow=nrow(fuz.me), ncol=10)
for (i in 1:ncol(uPL.mat)){
  uPL.mat[,i]<- DSM_data_val$RK_preds + uPI.mat[,i]}

## PICP
bMat<- matrix(NA,nrow= nrow(fuz.me), ncol= 10)
for (i in 1:10){
bMat[,i]<- as.numeric(DSM_data_val$pH60_100cm <= uPL.mat[,i] & DSM_data_val$pH60_100cm >= lPL.mat[,i])} 

#make plot
par(mfrow=c(1,1))
cs<- c(99,97.5,95,90,80,60,40,20,10,5)
plot(cs,((colSums(bMat)/ nrow(bMat))*100), ylab = "PICP", xlab = "confidence level")
# draw 1:1 line
abline(a=0, b = 1, col = "red")

#prediction interval width (averaged)
as.matrix(mean(uPL.mat[,4]-lPL.mat[,4]))



## MAPPING
# random forest model extension
map.Rf<- terra::predict(object = hv.sub.rasters, model = hv.RF.Exp,  na.rm = TRUE)
 
# kriged residuals
map.KR <- terra::interpolate(object = hv.sub.rasters, model = gR, xyOnly = TRUE)
 
# combine
map.final<- map.Rf + map.KR[[1]]
plot(map.final)

# Prediction Intervals
# get rasters into a data frame to advance calculation of memberships
hunterCovs.df <- data.frame(cellNos = seq(1:ncell(hv.sub.rasters)))
vals <- as.data.frame(terra::values(hv.sub.rasters))
hunterCovs.df<- cbind(hunterCovs.df, vals)
hunterCovs.df <- hunterCovs.df[complete.cases(hunterCovs.df), ]
cellNos <- c(hunterCovs.df$cellNos)
gXY <- data.frame(terra::xyFromCell(hv.sub.rasters, cellNos))
hunterCovs.df <- cbind(gXY, hunterCovs.df)
str(hunterCovs.df)

# run fuzme allocation function
# load FKM object if needed
#tester<- readRDS(file = "fkme_example_out.rds")
#or..
fuz.me_ALL<- fuzExall (data= hunterCovs.df[,4:ncol(hunterCovs.df)]  ,
                       centroid= tester$centroid ,
                       phi= 1.2, distype = 3, 
                       W = tester$distNormMat, alfa = tester$alfa)
head(fuz.me_ALL$membership)

# attribute class allocation to maximum membership
membs.table<- as.data.frame(fuz.me_ALL$membership)
membs.table$class<- NA
for (i in 1:nrow(membs.table)){
  mbs2<- membs.table[i,1:5]
  #which is the maximum probability on this row
  membs.table$class[i]<- which(mbs2 == max(mbs2))[1]}

#combine coordinates to memberships
hvCovs<- cbind(hunterCovs.df[,1:2], membs.table)

# Create rasters of memberships and class
map.class1mem<- terra::rast(hvCovs[,c(1,2,3)], type = "xyz")
names(map.class1mem)<- "class_1"
map.class2mem<- terra::rast(hvCovs[,c(1,2,4)], type = "xyz")
names(map.class2mem)<- "class_2"
map.class3mem<- terra::rast(hvCovs[,c(1,2,5)], type = "xyz")
names(map.class3mem)<- "class_3"
map.class4mem<- terra::rast(hvCovs[,c(1,2,6)], type = "xyz")
names(map.class4mem)<- "class_4"
map.classExtramem<- terra::rast(hvCovs[,c(1,2,7)], type = "xyz")
names(map.classExtramem)<- "class_ext"
map.class<- terra::rast(hvCovs[,c(1,2,8)], type = "xyz")
names(map.class)<- "class"

## PLOTTING
par(mfrow=c(3,2))
plot(map.class1mem,main="class 1",col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2) )
plot(map.class2mem,main="class 2", col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2))
plot(map.class3mem,main="class 3", col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2))
plot(map.class4mem,main="class 4",col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2) )
plot(map.classExtramem, main="Extragrade",col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2))
levels(map.class) = data.frame(value=1:5, desc = c("Class 1","Class 2", "Class 3","Class 4", "Extragrade"))
area_colors <- c("#FFFF00", "#1D0BE0", "#1CEB15","#808080" ,"#C91601")
plot(map.class, col = area_colors,plg = list(loc = "bottomleft",cex=0.6))


# Mapping of upper and lower predicition limits
#Lower limits for each class
quanMat1["90",]
#upper limits for each class
quanMat2["90",]

# stack the rasters
s2<- c(map.class1mem,map.class2mem,map.class3mem, map.class4mem ,map.classExtramem)
s2

#lower limit
f1 <- function(x) ((x[1]*quanMat1["90",1])  + 
                     (x[2]*quanMat1["90",2])+ 
                     (x[3]*quanMat1["90",3]) +  
                     (x[4]*quanMat1["90",4]) + 
                     (x[5]*quanMat1["90",5]))
mapRK.lower <- terra::app(x = s2, fun=f1)
plot(mapRK.lower)

#upper limit
f2 <- function(x) ((x[1]*quanMat2["90",1])  + 
                     (x[2]*quanMat2["90",2]) + 
                     (x[3]*quanMat2["90",3]) +  
                     (x[4]*quanMat2["90",4]) +
                     (x[5]*quanMat2["90",5]))
mapRK.upper <- terra::app(x = s2, fun=f2)
plot(mapRK.upper)

## Final maps
#Lower prediction limit
map.final.lower <- map.final + mapRK.lower
#Upper prediction limit
map.final.upper <- map.final + mapRK.upper
#Prediction interval range
map.final.pir <- map.final.upper - map.final.lower

## PLOTTING
 # color ramp
 phCramp<- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598",
        "#abdda4", "#66c2a5" , "#3288bd","#5e4fa2","#542788", "#2d004b" )
 brk <- c(2:14)
 par(mfrow=c(2,2))
 plot(map.final.lower, main= "90% Lower prediction limit", breaks=brk, col=phCramp)
 plot(map.final, main= "Prediction",breaks=brk, col=phCramp)
 plot(map.final.upper, main= "90% Upper prediction limit",breaks=brk, col=phCramp)
 plot(map.final.pir, main= "Prediction limit range",col = terrain.colors( length(seq(0, 6.5, by = 1))-1),
      axes = FALSE, breaks= seq(0, 6.5, by = 1))
 
## END