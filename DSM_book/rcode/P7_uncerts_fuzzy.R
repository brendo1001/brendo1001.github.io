##Some methods for the quantification of prediction uncertainties for digital soil mapping: 
## Empirical uncertainty quantification through fuzzy clustering and cross validation


#Library
library(ithir)
library(sp)
library(rgdal)
library(raster)



##DATA
#Point data
data(HV_subsoilpH)
str(HV_subsoilpH)

#Raster data
data(hunterCovariates_sub)
hunterCovariates_sub



#subset data for modeling
set.seed(667)
training <- sample(nrow(HV_subsoilpH), 0.7 * nrow(HV_subsoilpH))
cDat <- HV_subsoilpH[training, ]
vDat <- HV_subsoilpH[-training, ]

## Model fitting
library(randomForest)

hv.RF.Exp <- randomForest(pH60_100cm ~ Terrain_Ruggedness_Index + AACN + Landsat_Band1 + 
                            Elevation + Hillshading + Light_insolation + Mid_Slope_Positon + 
                            MRVBF + NDVI + TWI + Slope, data = cDat , importance = TRUE, ntree = 1000)
# goodness of fit
goof(observed = cDat$pH60_100cm , predicted = predict(hv.RF.Exp, newdata = cDat),plot.it=FALSE)


#Estimate the residual
cDat$residual<- cDat$pH60_100cm -  predict(hv.RF.Exp, newdata = cDat)

#residual variogram model
coordinates(cDat)<- ~X+Y
vgm1 <- variogram(residual ~ 1, data=cDat, width = 200)
mod <- vgm(psill = var(cDat$residual), "Sph", range = 10000, nugget = 0)
model_1 <- fit.variogram(vgm1, mod)
model_1

gOK <- gstat(NULL, "hunterpH_residual_RF", residual ~ 1, cDat, model = model_1)



## LEAVE - ONE - OUT - CROSS - VALIDATION

# Note: the following step could take a little time to compute.
# This data can be loaded to avoid the following step of LOCV
# Just get your file paths right
#looResidualdata
cDat1<- read.table(file="Z:/Dropbox/2018/DSM_workshopMaterials/uncertaintyAnalysis/work2015/fuzzyK/hunter_DSMDat.txt",header = T,sep = ",")
names(cDat1)
# End note



## #Uncertainty analysis
 cDat1<- as.data.frame(cDat)
 names(cDat1)
 cDat1.r1<- cDat1
 target.C.r1<- cDat1.r1$pH60_100cm
 
 looResiduals <- numeric(nrow(cDat1.r1))
 for(i in 1:nrow(cDat1.r1)){
   looRFPred<-randomForest(pH60_100cm ~ Terrain_Ruggedness_Index + AACN + Landsat_Band1 +
                           Elevation + Hillshading + Light_insolation + Mid_Slope_Positon +
                           MRVBF + NDVI + TWI + Slope, data = cDat1.r1[-i,] , importance = TRUE, ntree = 1000)
 
   cDat11.r1.sub<-  cDat1.r1[-i,]
   cDat11.r1.sub$pred<-predict(looRFPred, newdata = cDat11.r1.sub)
   cDat11.r1.sub$resids<- target.C.r1[-i] - cDat11.r1.sub$pred
   #residual variogram
   vgm.r1 <- variogram(resids~1, ~X+Y, cDat11.r1.sub, width= 200)
   mod.r1<-vgm(psill= var(cDat11.r1.sub$resids), "Sph", range= 10000, nugget = 0)
   model_1.r1<-fit.variogram(vgm.r1, mod.r1)
   model_1.r1
   #interpolate residual
   int.resids1.r1<- krige(cDat11.r1.sub$resids~1,locations= ~X+Y, data= cDat11.r1.sub, newdata= cDat1.r1[i,c("X","Y")] , model = model_1.r1, debug.level= 0)[,3]
   looPred<-predict( looRFPred, newdata = cDat1.r1[i,])
   looResiduals[i]<- target.C.r1[i] - (looPred+int.resids1.r1)}
 
 #Combine residual to main data frame
 cDat1<- cbind(cDat1, looResiduals)



## FUZZY KMEANS with EXTRAGRADES
#may need to install the package
#install.packages("devtools") 
#library(devtools)
#install_bitbucket("brendo1001/fuzme/rPackage/fuzme")
 
library(fuzme) 

 #Parameterize fuzzy objective function
 # Note: the following step could take a little time to compute.
 # This data can be loaded to avoid the following step of FKM with extragrade
 # Just get your file paths right
 load("alfa.t.rda")
 # End Note
 
 data.t<-  cDat1[,4:14] # data to be clustered
 nclass.t<- 4 # number of clusters
 phi.t<- 1.2
 distype.t<- 3 #3 = Mahalanobis distance
 Uereq.t<- 0.10 #average extragrade membership
 
 #initial membership matrix
 scatter.t<- 0.2    # scatter around initial membership
 ndata.t<- dim(data.t)[1]
 U.t<- initmember(scatter = scatter.t,nclass = nclass.t, ndata = ndata.t)
 
 #run fuzzy objective function
 alfa.t<- fobjk(Uereq= Uereq.t,nclass= nclass.t, data= data.t, U= U.t, phi= phi.t, distype= distype.t)
 alfa.t

## FKM with extragrade
 # Note: the following step could take a little time to compute.
 # This data can be loaded to avoid the following step of FKM with extragrade
 # Just get your file paths right
 load("fkme_test.rda")
 # End Note

 tester<- fkme(nclass = nclass.t, data = data.t, U = U.t, phi = phi.t, alfa= alfa.t, maxiter =500, distype = distype.t,toldif = 0.01, verbose = 1)


 ## Fuzzy performance indices
fvalidity(U = tester$membership[,1:4], dist = tester$distance, centroid = tester$centroid, nclass = 4 ,phi = 1.2, W= tester$distNormMat )

## Confusion index
mean(confusion(nclass = 5 ,U= tester$membership))
# Note number of cluster is set to 5 to account for the
# Additional extragrade cluster.

## Assign class for each point
membs<- as.data.frame(tester$membership)
membs$class<- 99999
for (i in 1:nrow(membs)){
  mbs2<- membs[i,1:ncol(tester$membership) ]
  #which is the maximum probability on this row
  membs$class[i]<- which(mbs2 == max(mbs2))[1]
}
membs$class<- as.factor(membs$class)
summary(membs$class)

#combine
cDat1<- cbind(cDat1, membs$class)
names(cDat1)[ncol(cDat1)]<- "class"
levels(cDat1$class)

## QUANTILES OF RESIDUALS IN EACH CLASS FOR CLASS PREDICTION LIMITS
cDat2<- split(cDat1, cDat1$class)

#cluster lower prediction limits
quanMat1<- matrix(NA, ncol=10, nrow=length(cDat2))
for (i in 1:length(cDat2)){
  quanMat1[i,]<- quantile(cDat2[[i]][,"looResiduals"], probs = c(0.005,0.0125,0.025,0.05,0.1,0.2,0.3,0.4,0.45,0.475), na.rm = FALSE,names = F, type = 7)}
row.names(quanMat1)<- levels(cDat1$class) 
quanMat1[nrow(quanMat1),]<- quanMat1[nrow(quanMat1),]*2
quanMat1<- t(quanMat1)
row.names(quanMat1)<- c(99,97.5,95,90,80,60,40,20,10,5) #

#cluster upper prediction limits
quanMat2<- matrix(NA, ncol=10, nrow=length(cDat2))
for (i in 1:length(cDat2)){
  quanMat2[i,]<- quantile(cDat2[[i]][,"looResiduals"], probs = c(0.995,0.9875,0.975,0.95,0.9,0.8,0.7,0.6,0.55,0.525), na.rm = FALSE,names = F, type = 7)}
quanMat2[quanMat2<0] <- 0
row.names(quanMat2)<- levels(cDat1$class) 
quanMat2[nrow(quanMat2),]<- quanMat2[nrow(quanMat2),]*2
quanMat2<- t(quanMat2)
row.names(quanMat2)<- c(99,97.5,95,90,80,60,40,20,10,5) #





## VALIDATION
vDat1<- as.data.frame(vDat)
names(vDat1)

#covariates of the validation data
vCovs<- vDat1[,c("Terrain_Ruggedness_Index","AACN","Landsat_Band1","Elevation","Hillshading","Light_insolation","Mid_Slope_Positon","MRVBF","NDVI","TWI","Slope" )]

# run fkme allocation function
fuzAll<- fuzExall(data= vCovs,phi= 1.2,centroid= tester$centroid, distype= 3,W= tester$distNormMat, alfa= tester$alfa)

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

#Regression kriging predictions
vPreds<- predict(hv.RF.Exp, newdata = vDat)
coordinates(vDat) <- ~X + Y
OK.preds.V <- as.data.frame(krige(residual ~ 1, cDat, model = model_1, newdata = vDat))
OK.preds.V$randomForest<- vPreds
OK.preds.V$finalP<-OK.preds.V$randomForest+OK.preds.V$var1.pred 

#Add prediction limits to regression kriging predictions
vDat1<- cbind(vDat1,OK.preds.V$finalP)
names(vDat1)[ncol(vDat1)]<- "RF_rkFin"

#Derive validation lower prediction limits
lPL.mat<- matrix(NA,nrow=nrow(fuz.me), ncol=10)
for (i in 1:ncol(lPL.mat)){
  lPL.mat[,i]<- vDat1$RF_rkFin+ lPI.mat[,i]}

#Derive validation upper prediction limits
uPL.mat<- matrix(NA,nrow=nrow(fuz.me), ncol=10)
for (i in 1:ncol(uPL.mat)){
  uPL.mat[,i]<- vDat1$RF_rkFin+ uPI.mat[,i]}

## PICP
bMat<- matrix(NA,nrow= nrow(fuz.me), ncol= 10)
for (i in 1:10){
bMat[,i]<- as.numeric(vDat1$pH60_100cm <= uPL.mat[,i] & vDat1$pH60_100cm >= lPL.mat[,i])} 

colSums(bMat)/ nrow(bMat)

#prediction interval width (averaged)
as.matrix(mean(uPL.mat[,4]-lPL.mat[,4]))




## OPTIMISATION OF CLUSTERING CONFIGURATION
nclass.t<- seq(2,6,1)
nclass.t
phi.t<- seq(1.2,1.6, 0.1)   
phi.t

# Note: For optimisation it is necessary to run through the FKM and calculate the necessary parameters for a number of cluster
# configurations. This would require looping through different combinations of class number and fuzzy exponent.
# Obviously this will take some time so some pre-prepared data is supplied. 
# Just get your file paths right
fkme.outs<- read.table(file="fuzzy_tableOuts.txt",header = T,sep = ",")
# End Note
fkme.outs

## 3 class with 1.2 fuzzy exponent seems the best option
## Load data
load(file = "Z:/Dropbox/2018/DSM_workshopMaterials/fkme_final.rda")
#or..
U.t<- initmember(scatter = 0.2,nclass = 3, ndata = ndata.t)
fkme.fin<- fkme(nclass = 3, data = data.t, U = U.t, phi = 1.2, alfa= 0.008058919, maxiter =500, distype = 3,toldif = 0.01, verbose = 1)

#looResidualdata
str(cDat1)

#Assign cluster to respective data point
membs<- as.data.frame(fkme.fin$membership)
membs$class<- 99999
for (i in 1:nrow(membs)){
  mbs2<- membs[i,1:ncol(fkme.fin$membership) ]
  #which is the maximum probability on this row
  membs$class[i]<- which(mbs2 == max(mbs2))[1]
}
membs$class<- as.factor(membs$class)
summary(membs$class)

#combine to main data frame
cDat1<- cbind(cDat1, membs$class)
names(cDat1)[ncol(cDat1)]<- "class"
levels(cDat1$class)

#split data frame based on class
cDat2<- split(cDat1, cDat1$class)

#cluster lower prediction limits
quanMat1<- matrix(NA, ncol=10, nrow=length(cDat2))
for (i in 1:length(cDat2)){
  quanMat1[i,]<- quantile(cDat2[[i]][,"looResiduals"], probs = c(0.005,0.0125,0.025,0.05,0.1,0.2,0.3,0.4,0.45,0.475), na.rm = FALSE,names = F, type = 7)}
row.names(quanMat1)<- levels(cDat1$class) 
quanMat1[nrow(quanMat1),]<- quanMat1[nrow(quanMat1),]*2
quanMat1<- t(quanMat1)
row.names(quanMat1)<- c(99,97.5,95,90,80,60,40,20,10,5) #

#cluster upper prediction limits
quanMat2<- matrix(NA, ncol=10, nrow=length(cDat2))
for (i in 1:length(cDat2)){
  quanMat2[i,]<- quantile(cDat2[[i]][,"looResiduals"], probs = c(0.995,0.9875,0.975,0.95,0.9,0.8,0.7,0.6,0.55,0.525), na.rm = FALSE,names = F, type = 7)}
quanMat2[quanMat2<0] <- 0
row.names(quanMat2)<- levels(cDat1$class) 
quanMat2[nrow(quanMat2),]<- quanMat2[nrow(quanMat2),]*2
quanMat2<- t(quanMat2)
row.names(quanMat2)<- c(99,97.5,95,90,80,60,40,20,10,5) 





## MAPPING
 map.Rf <- predict(hunterCovariates_sub,hv.RF.Exp,filename="RF_HV.tif",format="GTiff",overwrite=T)
 
 #kriged residuals
 crs(hunterCovariates_sub)<- NULL
 map.KR <- interpolate(hunterCovariates_sub, gOK, xyOnly = TRUE, index = 1, filename = "krigedResid_RF.tif", format= "GTiff", datatype = "FLT4S", overwrite = TRUE)
 
 #raster stack of predictions and residuals
 r2<- stack(map.Rf,map.KR)
 f1 <- function(x) calc(x, sum)
 #add both maps
 mapRF.fin <- calc(r2, fun=sum, filename="RF_RF.tif",format="GTiff",overwrite=T)

#Prediction Intervals
hunterCovs.df <- data.frame(cellNos = seq(1:ncell(hunterCovariates_sub)))
vals <- as.data.frame(getValues(hunterCovariates_sub))
hunterCovs.df<- cbind(hunterCovs.df, vals)
hunterCovs.df <- hunterCovs.df[complete.cases(hunterCovs.df), ]
cellNos <- c(hunterCovs.df$cellNos)
gXY <- data.frame(xyFromCell(hunterCovariates_sub, cellNos, spatial = FALSE))
hunterCovs.df <- cbind(gXY, hunterCovs.df)
str(hunterCovs.df)

# run fuzme allocation function
# load data
load(file = "fkme_allocationALL.rda")
#or..
fuz.me_ALL<- fuzExall (data= hunterCovs.df[,4:ncol(hunterCovs.df)]  ,centroid= fkme.fin$centroid ,phi= 1.2, distype = 3, W = fkme.fin$distNormMat, alfa = fkme.fin$alfa)
head(fuz.me_ALL$membership)

#combine
hvCovs<- cbind(hunterCovs.df[,1:2], fuz.me_ALL)
# Create raster 
map.class1mem<- rasterFromXYZ(hvCovs[,c(1,2,3)])
names(map.class1mem)<- "class_1"
map.class2mem<- rasterFromXYZ(hvCovs[,c(1,2,4)])
names(map.class2mem)<- "class_2"
map.class3mem<- rasterFromXYZ(hvCovs[,c(1,2,5)])
names(map.class3mem)<- "class_3"
map.classExtramem<- rasterFromXYZ(hvCovs[,c(1,2,6)])
names(map.classExtramem)<- "class_ext"

## PLOTTING
 par(mfrow=c(2,2))
 plot(map.class1mem,main="cluster 1",col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2) )
 plot(map.class2mem,main="cluster 2", col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2))
 plot(map.class3mem,main="cluster 3", col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2))
 plot(map.classExtramem, main="Extragrade",col = terrain.colors( length(seq(0, 1, by = 0.2))-1), axes = FALSE, breaks= seq(0, 1, by = 0.2))


#Lower limits
quanMat1["90",]
#upper limits
quanMat2["90",]

#Raster stack
 s2<- stack(map.class1mem,map.class2mem,map.class3mem,map.classExtramem)

#lower limit
f1 <- function(x) ((x[1]*quanMat1["90",1])  + (x[2]*quanMat1["90",2])+ (x[3]*quanMat1["90",3]) +  (x[4]*quanMat1["90",4]))
mapRK.lower <- calc(s2, fun=f1, filename="RF_lowerLimit.tif",format="GTiff",overwrite=T)

#upper limit
f1 <- function(x) ((x[1]*quanMat2["90",1])  + (x[2]*quanMat2["90",2])+ (x[3]*quanMat2["90",3]) +  (x[4]*quanMat2["90",4]))
mapRK.upper <- calc(s2, fun=f1, filename="RF_upperLimit.tif",format="GTiff",overwrite=T)


## Final maps
 #raster stack
 s3<- stack(mapRF.fin,mapRK.lower,mapRK.upper)

 #Lower prediction limit
 f1 <- function(x) (x[1]+x[2])
 mapRF.lowerPI <- calc(s3, fun=f1, filename="RF_lowerPL.tif",format="GTiff",overwrite=T)
 
 #Upper prediction limit
 f1 <- function(x) (x[1]+x[3])
 mapRF.upperPI <- calc(s3, fun=f1, filename="RF_upperPL.tif",format="GTiff",overwrite=T)

#Prediction interval range
 r2<- stack(mapRF.lowerPI,mapRF.upperPI)
 mapRF.PIrange <- calc(r2, fun=diff, filename="cubistRK_PIrange.tif",format="GTiff",overwrite=T)



 
 
## PLOTTING
 # color ramp
 phCramp<- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598",
        "#abdda4", "#66c2a5" , "#3288bd","#5e4fa2","#542788", "#2d004b" )
 brk <- c(2:14)
 par(mfrow=c(2,2))
 plot(mapRF.lowerPI, main= "90% Lower prediction limit", breaks=brk, col=phCramp)
 plot(mapRF.fin, main= "Prediction",breaks=brk, col=phCramp)
 plot(mapRF.upperPI, main= "90% Upper prediction limit",breaks=brk, col=phCramp)
 plot(mapRF.PIrange, main= "Prediction limit range",col = terrain.colors( length(seq(0, 6.5, by = 1))-1),
      axes = FALSE, breaks= seq(0, 6.5, by = 1))


 
 
 
## VALIDATION OUTCOME
#regression kriging
goof(observed =vDat$pH60_100cm, predicted = OK.preds.V$finalP,plot.it = FALSE ) 

#Random Forest
goof(observed =vDat$pH60_100cm, predicted = OK.preds.V$randomForest,plot.it = FALSE ) 



## UNCERTAINTY QUANTIFICATION
vDat1<- as.data.frame(vDat)
names(vDat1)
#covariates of the validation data
vCovs<- vDat1[,c("Terrain_Ruggedness_Index","AACN","Landsat_Band1","Elevation","Hillshading","Light_insolation","Mid_Slope_Positon","MRVBF","NDVI","TWI","Slope" )]

# run fkme allocation function
fuzAll<- fuzExall (data= vCovs,phi= 1.2,centroid= fkme.fin$centroid,distype= 3,W= fkme.fin$distNormMat, alfa= fkme.fin$alfa)
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

#Regression kriging predictions
vPreds<- predict(hv.RF.Exp, newdata = vDat)
OK.preds.V <- as.data.frame(krige(residual ~ 1, cDat, model = model_1, newdata = vDat))
OK.preds.V$randomForest<- vPreds
OK.preds.V$finalP<-OK.preds.V$randomForest+OK.preds.V$var1.pred 

#Add prediction limits to regression kriging predictions
vDat1<- cbind(vDat1,OK.preds.V$finalP)
names(vDat1)[ncol(vDat1)]<- "RF_rkFin"

#Derive validation lower prediction limits
lPL.mat<- matrix(NA,nrow=nrow(fuz.me), ncol=10)
for (i in 1:ncol(lPL.mat)){
  lPL.mat[,i]<- vDat1$RF_rkFin+ lPI.mat[,i]}

#Derive validation upper prediction limits
uPL.mat<- matrix(NA,nrow=nrow(fuz.me), ncol=10)
for (i in 1:ncol(uPL.mat)){
  uPL.mat[,i]<- vDat1$RF_rkFin+ uPI.mat[,i]}

## PICP
bMat<- matrix(NA,nrow= nrow(fuz.me), ncol= 10)
for (i in 1:10){
bMat[,i]<- as.numeric(vDat1$pH60_100cm <= uPL.mat[,i] & vDat1$pH60_100cm >= lPL.mat[,i])} 

colSums(bMat)/ nrow(bMat)

## PLOT
 cs<- c(99,97.5,95,90,80,60,40,20,10,5) # confidence level
 plot(cs,((colSums(bMat)/ nrow(bMat))*100))
 abline(a = 0, b = 1, lty = 2, col="red")

## PREDICTION INTERVAL RANGE
quantile(uPL.mat[,4] - lPL.mat[,4])

