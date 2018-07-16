## Combining continuous and categorical modeling: Digital soil mapping of soil horizons and their depths


#library
library(ithir)
library(sp);library(raster);library(aqp)

#data (download from wesite)
load("HV_horizons.rda")
str(dat)
#convert data to spatial object
coordinates(dat)<- ~ e + n

#covariates
data(hunterCovariates)
names(hunterCovariates)
#resolution
res(hunterCovariates)
#raster properties
dim(hunterCovariates)

## Overlay points onto raster
plot(hunterCovariates[["AACN"]])
points(dat,pch=20)

#Covariate extract for points
ext<- extract(hunterCovariates, dat, df=T, method="simple")
w.dat<- cbind(as.data.frame(dat), ext)

#remove sites with missing covariates
x.dat<- w.dat[complete.cases(w.dat[,27:31]),]

## Set target variable and subset data for validation
#A1 Horizon
x.dat$A1<- as.factor(x.dat$A1)
#random subset
set.seed(123)
training <- sample( nrow(x.dat), 0.75 *nrow(x.dat)) 
#calibration dataset
dat.C<- x.dat[training,] 
#validation dataset
dat.V<- x.dat[-training,] 

## Presence/absence model
library(nnet)
library(MASS)
 # A1 presence or absence model
mn1<- multinom(formula = A1 ~ AACN + Drainage.Index + Light.Insolation + TWI + Gamma.Total.Count,
                data = dat.C)
#stepwise variable selection
mn2<- stepAIC(mn1,direction="both", trace=FALSE)
summary(mn2)

## Goodness of fit
#calibration
mod.pred<-predict(mn2, newdata = dat.C,type="class")
goofcat(observed = dat.C$A1,predicted = mod.pred)

#validation
val.pred<-predict(mn2, newdata = dat.V,type="class")
goofcat(observed = dat.V$A1,predicted = val.pred)

## Model of horizon depth
#Remove missing values
#calibration
mod.dat <- dat.C[!is.na(dat.C$A1d),]  

#validation
val.dat <- dat.V[!is.na(dat.V$A1d),] 

#Fit quantile regression forest
library(quantregForest)
qrf <- quantregForest(x=mod.dat[,27:31], y=mod.dat$A1d, importance=TRUE)

## Goodness of fit
## Calibration
quant.cal  <- predict(qrf, newdata= mod.dat[,27:31], all=T)
goof(observed = mod.dat$A1d, predicted = quant.cal[,2])

#Validation
quant.val  <- predict(qrf, newdata= val.dat[,27:31], all=T)
goof(observed = val.dat$A1d, predicted = quant.val[,2])

#PICP
sum(quant.val[,1]<=val.dat$A1d & quant.val[,2]>=val.dat$A1d)/nrow(val.dat)


## Plotting
vv.dat<- read.table(file="validation_outs.txt", sep = ",",header = T)
dat.V<- read.table(file="validation_obs.txt", sep = ",",header= T)


#Validation data horizon observations (1st 3 rows)
dat.V[1:3,c(1,4:14)]

#Associated model predictions (1st 3 rows)
vv.dat[1:3,1:12]

#matched soil profiles
sum(dat.V$A1==vv.dat$a1 & dat.V$A2==vv.dat$a2 & dat.V$AP==vv.dat$ap & dat.V$B1==vv.dat$b1 &
  dat.V$B21==vv.dat$b21 & dat.V$B22==vv.dat$b22 & dat.V$B23==vv.dat$b23 & dat.V$B24==vv.dat$b24 &
  dat.V$B3==vv.dat$b3 & dat.V$BC==vv.dat$bc & dat.V$C==vv.dat$c)/nrow(dat.V)

#Subset of matching data (observations)
match.dat<- dat.V[which(dat.V$A1==vv.dat$a1 & dat.V$A2==vv.dat$a2 & dat.V$AP==vv.dat$ap & dat.V$B1==vv.dat$b1 & dat.V$B21==vv.dat$b21 & dat.V$B22==vv.dat$b22 & dat.V$B23==vv.dat$b23 & dat.V$B24==vv.dat$b24 & dat.V$B3==vv.dat$b3 & dat.V$BC==vv.dat$bc & dat.V$C==vv.dat$c),]

#Subset of matching data (predictions)
match.dat.P<- vv.dat[which(dat.V$A1==vv.dat$a1 & dat.V$A2==vv.dat$a2 & dat.V$AP==vv.dat$ap & dat.V$B1==vv.dat$b1 & dat.V$B21==vv.dat$b21 & dat.V$B22==vv.dat$b22 & dat.V$B23==vv.dat$b23 & dat.V$B24==vv.dat$b24 & dat.V$B3==vv.dat$b3 & dat.V$BC==vv.dat$bc & dat.V$C==vv.dat$c),]

match.dat[49,] #observation
match.dat.P[49,] #prediction

#Horizon classes
H1<- c("AP", "B21", "B22", "BC")

#Extract horizon depths then combine to create soil profiles
p1<- c(22,31,27,32)
p2<- c(10, 30, 15, 45)
p1u<-c(0, (0+p1[1]), (0+p1[1]+p1[2]),(0+p1[1]+p1[2]+p1[3]))
p1l<-c(p1[1], (p1[1]+p1[2]), (p1[1]+p1[2]+p1[3]),(p1[1]+p1[2]+p1[3]+p1[4]))
p2u<-c(0, (0+p2[1]), (+p2[1]+p2[2]),(+p2[1]+p2[2]+p2[3]))
p2l<-c(p2[1], (p2[1]+p2[2]), (p2[1]+p2[2]+p2[3]),(p2[1]+p2[2]+p2[3]+p2[4]))

#Upper depths
U1<- c(p1u,p2u)
#Lower depths
L1<- c(p1l,p2l)

#Soil profile names
S1<- c("predicted profile","predicted profile","predicted profile","predicted profile",
        "observed profile","observed profile","observed profile","observed profile")

#Random soil colors selected to distinguish between horizons
hue<-c("10YR", "10R", "10R", "10R","10YR", "10R", "10R", "10R")
val<- c(4,5,7,6,4,5,7,6)
chr<- c(3,8,8,1,3,8,8,1)
 
#Combine all the data
TT1<- data.frame(S1,U1,L1,H1,hue,val,chr)

# Convert munsell colors to rgb
TT1$soil_color <- with(TT1, munsell2rgb(hue, val, chr))

#Upgrade to soil profile collection
depths(TT1) <- S1 ~ U1 + L1

#Plot
plot(TT1, name='H1',colors="soil_color")
title('Selected soil with AP horizon', cex.main=0.75)



## MAPPING
## #Apply A1 horizon presence/absence model spatially
## #Using the raster multi-core facility
beginCluster(4)
A1.class<-clusterR(hunterCovariates, predict, args=list(mn2, type="class"),filename="class_A1.tif",format="GTiff",progress="text",overwrite=T)

#Apply A1 horizon depth model spatially
#Using the raster multi-core facility
A1.depth<-clusterR(hunterCovariates, predict, args=list(qrf, index=2),filename="depth_A1.tif",format="GTiff",progress="text",overwrite=T)
endCluster()

#Mask out areas where horizon is absent
A1.class[A1.class == 0] <- NA
mr <- mask(A1.depth, A1.class)
writeRaster(mr,filename = "depth_A1_mask.tif",format="GTiff",overwrite=T)

##END

