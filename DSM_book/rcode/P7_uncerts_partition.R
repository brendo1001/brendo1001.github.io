##Some methods for the quantification of prediction uncertainties for digital soil mapping: 
## Data partitioning and cross validation approach


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
cDat<- HV_subsoilpH[training, ]
vDat<- HV_subsoilpH[-training, ]



## Model fit
library(Cubist)

#Cubist model
hv.cub.Exp <- cubist(x = cDat[, c("Terrain_Ruggedness_Index", "AACN", "Landsat_Band1", "Elevation", "Hillshading", "Light_insolation", "Mid_Slope_Positon", "MRVBF", "NDVI", "TWI", "Slope")], y = cDat$pH60_100cm, cubistControl(unbiased = TRUE,rules = 100, extrapolation = 10, sample = 0, label = "outcome"), committees = 1)
summary(hv.cub.Exp)

## goodness of fit (calibration)
goof(observed= cDat$pH60_100cm , predicted= predict(hv.cub.Exp, newdata = cDat))

## Model residuals
cDat$residual<- cDat$pH60_100cm -  predict(hv.cub.Exp, newdata = cDat)


#coordinates
coordinates(cDat) <- ~X + Y
#residual variogram model
vgm1 <- variogram(residual ~ 1, cDat, width = 200)
mod <- vgm(psill = var(cDat$residual), "Sph", range = 10000, nugget = 0)
model_1 <- fit.variogram(vgm1, mod)

gOK <- gstat(NULL, "hunterpH_cubistRES", residual ~ 1, cDat, model = model_1)
gOK


## Data partitions
#Assign a rule to each observation if more than one observation
cDat1<- as.data.frame(cDat)
cDat1$rule=9999
#rule 1
cDat1$rule[which(cDat1$NDVI <= -0.191489 & cDat1$TWI <= 13.17387 )] <- 1
#rule 2
cDat1$rule[which(cDat1$TWI > 13.17387 )] <- 2
##rule 3
cDat1$rule[which(cDat1$NDVI > -0.191489 & cDat1$TWI <= 13.17387 )] <- 3

cDat1$rule<- as.factor(cDat1$rule)
summary(cDat1$rule)

## Within each ruleset

#subset the data: RULESET1
cDat1.r1<- cDat1[which(cDat1$rule == 1),] 
target.C.r1<- cDat1.r1$pH60_100cm

########## Leave-one-out cross validation ###################
looResiduals1 <- numeric(nrow(cDat1.r1))
for(i in 1:nrow(cDat1.r1)){
  loocubistPred<-cubist(x= cDat1.r1[-i,4:14], y=target.C.r1[-i],cubistControl(unbiased = F, rules = 1,extrapolation = 5, sample = 0,seed = sample.int(4096, size = 1) - 1L,label = "outcome"),committees = 1)     # fit cubist model
  # fit cubist model
  cDat11.r1.sub<-  cDat1.r1[-i,]
  cDat11.r1.sub$pred<-predict(loocubistPred, newdata = cDat11.r1.sub,neighbors = 0)
  cDat11.r1.sub$resids<- target.C.r1[-i] - cDat11.r1.sub$pred 
  #residual variogram
  vgm.r1 <- variogram(resids~1, ~X+Y, cDat11.r1.sub, width= 100)
  mod.r1<-vgm(psill= var(cDat11.r1.sub$resids), "Sph", range= 10000, nugget = 0) 
  model_1.r1<-fit.variogram(vgm.r1, mod.r1)
  #interpolate residual on withheld point
  int.resids1.r1<- krige(cDat11.r1.sub$resids~1,locations= ~X+Y, data= cDat11.r1.sub, newdata= cDat1.r1[i,c("X","Y")] , model = model_1.r1, debug.level = 0)[,3]
  #Cubist model predict on withheld point
  looPred<-predict( loocubistPred, newdata = cDat1.r1[i,],neighbors = 0)
  # Add
  looResiduals1[i]<- target.C.r1[i] - (looPred+int.resids1.r1)}

#subset the data: RULESET2
cDat1.r2<- cDat1[which(cDat1$rule == 2),]
target.C.r2<- cDat1.r2$pH60_100cm


########## Leave-one-out cross validation #####################################################################################################
looResiduals2 <- numeric(nrow(cDat1.r2))
for(i in 1:nrow(cDat1.r2)){
  loocubistPred<-cubist(x= cDat1.r2[-i,4:14], y=target.C.r2[-i],cubistControl(unbiased = F, rules = 1,extrapolation = 5, sample = 0,seed = sample.int(4096, size = 1) - 1L,label = "outcome"),committees = 1)     # fit cubist model
  # fit cubist model
  cDat11.r2.sub<-  cDat1.r2[-i,]
  cDat11.r2.sub$pred<-predict(loocubistPred, newdata = cDat11.r2.sub,neighbors = 0)
  cDat11.r2.sub$resids<- target.C.r2[-i] - cDat11.r2.sub$pred 
  #residual variogram
  vgm.r2 <- variogram(resids~1, ~X+Y, cDat11.r2.sub, width= 100)
  mod.r2<-vgm(psill= var(cDat11.r2.sub$resids), "Sph", range= 10000, nugget = 0) 
  model_1.r2<-fit.variogram(vgm.r2, mod.r2)
  #interpolate residual
  int.resids1.r2<- krige(cDat11.r2.sub$resids~1,locations= ~X+Y, data= cDat11.r2.sub, newdata= cDat1.r2[i,c("X","Y")] , model = model_1.r2, debug.level = 0)[,3]
  looPred<-predict( loocubistPred, newdata = cDat1.r2[i,],neighbors = 0)
  looResiduals2[i]<- target.C.r2[i] - (looPred+int.resids1.r2)}
##############################

#subset the data: RULESET3
cDat1.r3<- cDat1[which(cDat1$rule == 3),]
target.C.r3<- cDat1.r3$pH60_100cm

########## Leave-one-out cross validation #####################################################################################################
looResiduals3 <- numeric(nrow(cDat1.r3))
for(i in 1:nrow(cDat1.r3)){
  loocubistPred<-cubist(x= cDat1.r3[-i,4:14], y=target.C.r3[-i],cubistControl(unbiased = F, rules = 1,extrapolation = 5, sample = 0,seed = sample.int(4096, size = 1) - 1L,label = "outcome"),committees = 1)     # fit cubist model
  # fit cubist model
  cDat11.r3.sub<-  cDat1.r3[-i,]
  cDat11.r3.sub$pred<-predict(loocubistPred, newdata = cDat11.r3.sub,neighbors = 0)
  cDat11.r3.sub$resids<- target.C.r3[-i] - cDat11.r3.sub$pred 
  #residual variogram
  vgm.r3 <- variogram(resids~1, ~X+Y, cDat11.r3.sub, width= 100)
  mod.r3<-vgm(psill= var(cDat11.r3.sub$resids), "Sph", range= 10000, nugget = 0) 
  model_1.r3<-fit.variogram(vgm.r3, mod.r3)
  model_1.r3
  #interpolate residual
  int.resids1.r3<- krige(cDat11.r3.sub$resids~1,locations= ~X+Y, data= cDat11.r3.sub, newdata= cDat1.r3[i,c("X","Y")] , model = model_1.r3, debug.level = 0)[,3]
  looPred<-predict( loocubistPred, newdata = cDat1.r3[i,],neighbors = 0)
  looResiduals3[i]<- target.C.r3[i] - (looPred+int.resids1.r3)                    # model residuals
}
#####################

## Quantiles of residual distribution within each ruleset
#Rule 1
#90% confidence
r1.ulPI<- quantile(looResiduals1, probs = c(0.05,0.95), na.rm = FALSE,names = F, type = 7) # rule lower and upper PI
r1.ulPI
#Confidence interval range
r1.q<- quantile(looResiduals1, probs = c(0.005, 0.995,0.0125, 0.9875,0.025,0.975,0.05,0.95,0.1,0.9,0.2,0.8,0.3,0.7,0.4,0.6,0.45,0.55,0.475,0.525), na.rm = FALSE,names = F, type = 7) 

#Rule 2
#90% confidence
r2.ulPI<- quantile(looResiduals2, probs = c(0.05,0.95), na.rm = FALSE,names = F, type = 7) # rule lower and upper PI
r2.ulPI
#Confidence interval range
r2.q<- quantile(looResiduals2, probs = c(0.005, 0.995,0.0125, 0.9875,0.025,0.975,0.05,0.95,0.1,0.9,0.2,0.8,0.3,0.7,0.4,0.6,0.45,0.55,0.475,0.525), na.rm = FALSE,names = F, type = 7) 

#Rule 3
#90% confidence
r3.ulPI<- quantile(looResiduals3, probs = c(0.05,0.95), na.rm = FALSE,names = F, type = 7) # rule lower and upper PI
r3.ulPI
#Confidence interval range
r3.q<- quantile(looResiduals3, probs = c(0.005, 0.995,0.0125, 0.9875,0.025,0.975,0.05,0.95,0.1,0.9,0.2,0.8,0.3,0.7,0.4,0.6,0.45,0.55,0.475,0.525), na.rm = FALSE,names = F, type = 7) 



## MAPPING
map.cubist <- predict(hunterCovariates_sub,hv.cub.Exp, args=list(neighbors = 0),filename="rk_cubist.tif",format="GTiff",overwrite=T)

#kriged residuals
map.cubist.res <- interpolate(hunterCovariates_sub, gOK, xyOnly = TRUE, index = 1, filename = "rk_residuals.tif", format= "GTiff", datatype = "FLT4S", overwrite = TRUE)
 
#raster stack of predictions and residuals
r2<- stack(map.cubist,map.cubist.res)
f1 <- function(x) calc(x, sum)
map.cubist.final <- calc(r2, fun=sum, filename="cubistRK.tif",format="GTiff",overwrite=T)

#Create new raster datasets for upper and lower prediction intervals
upper1<- raster(hunterCovariates_sub[[1]])
lower1<- raster(hunterCovariates_sub[[1]])
rule1<- raster(hunterCovariates_sub[[1]])
upper1<- writeStart(upper1,filename='cubRK_upper1.tif', format='GTiff', overwrite=TRUE)
lower1<- writeStart(lower1,filename='cubRK_lower1.tif', format='GTiff', overwrite=TRUE)
rule1<- writeStart(rule1,filename='cubRK_rule1.tif', format='GTiff', datatype="INT2S", overwrite=TRUE)

for(i in 1:dim(upper1)[1]){
   #extract raster information line by line
   cov.Frame<-  as.data.frame(getValues(hunterCovariates_sub,i))
   ulr.Frame<-  matrix(NA,ncol=3,nrow=dim(upper1)[2])
   # append in partition information
 
   #rule 1
   ulr.Frame[which(cov.Frame$NDVI <= -0.191489 & cov.Frame$TWI <= 13.17387),1] <- r1.ulPI[2]
   ulr.Frame[which(cov.Frame$NDVI <= -0.191489 & cov.Frame$TWI <= 13.17387),2] <- r1.ulPI[1]
   ulr.Frame[which(cov.Frame$NDVI <= -0.191489 & cov.Frame$TWI <= 13.17387),3] <- 1

    #rule 2
   ulr.Frame[which(cov.Frame$TWI > 13.17387),1] <- r2.ulPI[2]
   ulr.Frame[which(cov.Frame$TWI > 13.17387),2] <- r2.ulPI[1]
   ulr.Frame[which(cov.Frame$TWI > 13.17387 ),3] <- 2
   #rule 3
   ulr.Frame[which(cov.Frame$NDVI > -0.191489 & cov.Frame$TWI <= 13.17387 ),1] <- r3.ulPI[2]
   ulr.Frame[which(cov.Frame$NDVI > -0.191489 & cov.Frame$TWI <= 13.17387 ),2] <- r3.ulPI[1]
   ulr.Frame[which(cov.Frame$NDVI > -0.191489 & cov.Frame$TWI <= 13.17387 ),3] <- 3
 
   ulr.Frame<-as.data.frame(ulr.Frame)
   names(ulr.Frame)<- c("upper", "lower", "rule")
   # write to raster then close
   pred_upper<- ulr.Frame$upper
   pred_lower<- ulr.Frame$lower
   pred_rule<- ulr.Frame$rule
   upper1<- writeValues(upper1,pred_upper,i)
   lower1<- writeValues(lower1,pred_lower,i)
   rule1<- writeValues(rule1,pred_rule,i)
   print(i)}
 upper1<- writeStop(upper1)
 lower1<- writeStop(lower1)
 rule1<- writeStop(rule1)

 #raster stack of predictions and prediction limits
 r2<- stack(map.cubist.final,lower1) #lower
 mapRK.lower <- calc(r2, fun=sum, filename="cubistRK_lowerPL.tif",format="GTiff",overwrite=T)

 
 #raster stack of predictions and prediction limits
 r2<- stack(map.cubist.final,upper1) #upper
 mapRK.upper <- calc(r2, fun=sum, filename="cubistRK_upperPI.tif",format="GTiff",overwrite=T)

 #Prediction interval range
 r2<- stack(mapRK.lower,mapRK.upper) #diff
 mapRK.PIrange <- calc(r2, fun=diff, filename="cubistRK_PIrange.tif",format="GTiff",overwrite=T)

## PLOTTING
 # color ramp
 phCramp<- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598",
        "#abdda4", "#66c2a5" , "#3288bd","#5e4fa2","#542788", "#2d004b" )
 brk <- c(2:14)
 par(mfrow=c(2,2))
 plot(mapRK.lower, main= "90% Lower prediction limit", breaks=brk, col=phCramp)
 plot(map.cubist.final, main= "Prediction",breaks=brk, col=phCramp)
 plot(mapRK.upper, main= "90% Upper prediction limit",breaks=brk, col=phCramp)
 plot(mapRK.PIrange, main= "Prediction limit range", col = terrain.colors( length(seq(0, 6.5, by = 1))-1),
      axes = FALSE, breaks= seq(0, 6.5, by = 1))


 
## UNCERTAINTY MODEL VALIDATION
#Cubist model prediction 
vPreds<- predict(hv.cub.Exp, newdata = vDat)
#Residual prediction
coordinates(vDat)<- ~X+Y
OK.preds.V <- as.data.frame(krige(residual ~ 1, cDat, model = model_1, newdata = vDat))

#Regression kriging predictions
OK.preds.V$cubist<- vPreds
OK.preds.V$finalP<-OK.preds.V$cubist+OK.preds.V$var1.pred 

#Validation
#regression
goof(observed =vDat$pH60_100cm, predicted = OK.preds.V$cubist) 
#regression kriging
goof(observed =vDat$pH60_100cm, predicted = OK.preds.V$finalP) 

## Data partition
#Assign a rule to each observation if more than one obervation
vDat1<- as.data.frame(vDat)
# Insert for rules bit
vDat1$rule=9999
#rule 1
vDat1$rule[which(vDat1$NDVI <= -0.191489 & vDat1$TWI <= 13.17387 )] <- 1
#rule 2
vDat1$rule[which(vDat1$TWI > 13.17387 )] <- 2
##rule 3
vDat1$rule[which(vDat1$NDVI > -0.191489 & vDat1$TWI <= 13.17387 )] <- 3

vDat1$rule<- as.factor(vDat1$rule)
summary(vDat1$rule)

#append regression kriging predictions
vDat1<- cbind(vDat1,OK.preds.V[,"finalP"])
names(vDat1)[ncol(vDat1)]<- "RKpred"

#Upper PL
ulMat<- matrix(NA,nrow= nrow(vDat1), ncol=length(r1.q))
for (i in seq(2,20,2)){
  ulMat[which(vDat1$rule == 1 ),i] <- r1.q[i]
  ulMat[which(vDat1$rule == 2 ),i] <- r2.q[i]
  ulMat[which(vDat1$rule == 3 ),i] <- r3.q[i]}

#Lower PL
for (i in seq(1,20,2)){
  ulMat[which(vDat1$rule == 1 ),i] <- r1.q[i]
  ulMat[which(vDat1$rule == 2 ),i] <- r2.q[i]
  ulMat[which(vDat1$rule == 3 ),i] <- r3.q[i]}

#upper and lower prediction limits
ULpreds<- ulMat + vDat1$RKpred

#PICP
bMat<- matrix(NA,nrow= nrow(ULpreds), ncol= (ncol(ULpreds)/2))
cnt<- 1
for (i in seq(1,20,2)){
  bMat[,cnt] <- as.numeric(vDat1$pH60_100cm <= ULpreds[,i+1] & vDat1$pH60_100cm >= ULpreds[,i])
cnt<- cnt+1} 

colSums(bMat)/ nrow(bMat)

 #make plot
 cs<- c(99,97.5,95,90,80,60,40,20,10,5) # confidence level
 plot(cs,((colSums(bMat)/ nrow(bMat))*100))
 abline(a = 0, b = 1, lty = 2, col="red")

## Prediction interval range
quantile(ULpreds[,8] - ULpreds[,7])


## END

