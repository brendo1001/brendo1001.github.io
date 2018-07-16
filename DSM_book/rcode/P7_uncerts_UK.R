##Some methods for the quantification of prediction uncertainties for digital soil mapping: 
## Universal kriging prediction variance.


#Library
library(ithir)
library(sp)
library(rgdal)
library(raster)
library(gstat)


##DATA
#Point data
data(HV_subsoilpH)
str(HV_subsoilpH)

#Raster data
data(hunterCovariates_sub)
hunterCovariates_sub


#subset data for modeling
set.seed(123)
training <- sample(nrow(HV_subsoilpH), 0.7 * nrow(HV_subsoilpH))
cDat <- HV_subsoilpH[training, ] # calibration
vDat <- HV_subsoilpH[-training, ] # validation
nrow(cDat)
nrow(vDat)


#coordinates
coordinates(cDat) <- ~X + Y

#remove CRS from grids
crs(hunterCovariates_sub) <- NULL



## Linear regression model
#Full model
lm1<- lm(pH60_100cm ~ Terrain_Ruggedness_Index + AACN + Landsat_Band1 + Elevation + Hillshading + Light_insolation + Mid_Slope_Positon + MRVBF + NDVI + TWI + Slope, data = cDat   )

#Parsimous model
lm2<- step(lm1, direction = "both", trace = 0)
as.formula(lm2)
summary(lm2)

## Universal kriging model
vgm1 <- variogram(pH60_100cm ~ AACN + Landsat_Band1 + Hillshading + Mid_Slope_Positon + MRVBF + NDVI + TWI, cDat, width = 200)
mod <- vgm(psill = var(cDat$pH60_100cm), "Sph", range = 10000, nugget = 0)
model_1 <- fit.variogram(vgm1, mod)

gUK <- gstat(NULL, "hunterpH_UK", pH60_100cm ~ AACN + Landsat_Band1 + Hillshading + Mid_Slope_Positon + MRVBF + NDVI + TWI, cDat, model = model_1)
gUK

## Mapping
UK.P.map <- interpolate(hunterCovariates_sub, gUK, xyOnly = FALSE, index = 1, filename="UK_predMap.tif",format="GTiff",overwrite=T)

# prediction variance
UK.var.map <- interpolate(hunterCovariates_sub, gUK, xyOnly = FALSE, index = 2, filename="UK_predVarMap.tif",format="GTiff",overwrite=T)

#standard deviation
f2 <- function(x) (sqrt(x))
UK.stdev.map <- calc(UK.var.map, fun=f2,filename="UK_predSDMap.tif",format="GTiff",progress="text",overwrite=T)

#Z level
zlev<- qnorm(0.95)
f2 <- function(x) (x * zlev)
UK.mult.map <- calc(UK.stdev.map, fun=f2,filename="UK_multMap.tif",format="GTiff",progress="text",overwrite=T)
 
#Add and subtract mult from prediction
m1<- stack(UK.P.map,UK.mult.map)

#upper PL
f3 <- function(x) (x[1] + x[2])
UK.upper.map <- calc(m1, fun=f3,filename="UK_upperMap.tif",format="GTiff",progress="text",overwrite=T)

#lower PL
f4 <- function(x) (x[1] - x[2])
UK.lower.map <- calc(m1, fun=f4,filename="UK_lowerMap.tif",format="GTiff",progress="text",overwrite=T)

# prediction range
m2<- stack(UK.upper.map,UK.lower.map)

f5 <- function(x) (x[1] - x[2])
UK.piRange.map <- calc(m2, fun=f5,filename="UK_piRangeMap.tif",format="GTiff",progress="text",overwrite=T)

# color ramp
phCramp<- c("#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598",
        "#abdda4", "#66c2a5" , "#3288bd","#5e4fa2","#542788", "#2d004b" )
brk <- c(2:14)
#plotting
par(mfrow=c(2,2))
plot(UK.lower.map, main= "90% Lower prediction limit", breaks=brk, col=phCramp)
plot(UK.P.map, main= "Prediction",breaks=brk, col=phCramp)
plot(UK.upper.map, main= "90% Upper prediction limit",breaks=brk, col=phCramp)
plot(UK.piRange.map, main= "Prediction limit range", col = terrain.colors( length(seq(0, 6.5, by = 1))-1),
     axes = FALSE, breaks= seq(0, 6.5, by = 1) )




## VALIDATION
coordinates(vDat) <- ~X + Y

#Prediction
UK.preds.V <- as.data.frame(krige(pH60_100cm ~ AACN + Landsat_Band1 + Hillshading + Mid_Slope_Positon + MRVBF + NDVI + TWI, cDat, model = model_1, newdata = vDat))
UK.preds.V$stdev<- sqrt(UK.preds.V$var1.var)
str(UK.preds.V)

## confidence levels
qp<- qnorm(c(0.995,0.9875,0.975,0.95,0.9,0.8,0.7,0.6,0.55,0.525)) 


#zfactor multiplication
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
  bMat[,i] <- as.numeric(vDat$pH60_100cm <= uMat[,i] & vDat$pH60_100cm >= lMat[,i])} 

colSums(bMat)/ nrow(bMat)


#make plot
cs<- c(99,97.5,95,90,80,60,40,20,10,5)
plot(cs,((colSums(bMat)/ nrow(bMat))*100))

## Goodness of fit: validation
goof(observed = vDat$pH60_100cm , predicted = UK.preds.V$var1.pred)

## prediction range
cs<- c(99,97.5,95,90,80,60,40,20,10,5) # confidence level
colnames(lMat)<- cs
colnames(uMat)<- cs
quantile(uMat[,"90"] - lMat[,"90"])

