##Preparatory and exploratory data analysis for digital soil mapping



## libraries to load
library(ithir);library(ithir);library(raster);library(sp);library(gstat);library(nortest);library(fBasics);library(ggplot2)


## Soil Depth Functions

# small dataset from ithit 
data(oneProfile)
str(oneProfile)



## Fit mass preserving spline
eaFit <- ea_spline(oneProfile, var.name="C.kg.m3.",
        d= t(c(0,5,15,30,60,100,200)),lam = 0.1, vlow=0, 
        show.progress=FALSE )
str(eaFit)

## Plot spline outputs
par(mfrow=c(3,1))
for (i in 1:3){
  plot_ea_spline(splineOuts=eaFit, d= t(c(0,5,15,30,60,100,200)),
  maxd=200, type=i, plot.which=1, label="carbon density")}


## Intersecting soil point observations with environmental covariates

## soil point data
data(HV_subsoilpH)
str(HV_subsoilpH)

## Point data preparation
#round pH data to 2 decimal places
HV_subsoilpH$pH60_100cm<- round(HV_subsoilpH$pH60_100cm, 2)

#remove already intersected data
HV_subsoilpH<- HV_subsoilpH[,1:3]

#add an id column
HV_subsoilpH$id<- seq(1, nrow(HV_subsoilpH), by = 1)

#re-arrange order of columns
HV_subsoilpH<- HV_subsoilpH[,c(4,1,2,3)]

#Change names of coordinate columns
names(HV_subsoilpH)[2:3]<- c("x", "y")

#structure
str(HV_subsoilpH)


## Grid data
data(hunterCovariates_sub)
hunterCovariates_sub

## Basic plotting
## #plot raster
plot(hunterCovariates_sub[["Elevation"]], main="Hunter Valley elevation map with overlayed point locations")

## ##plot points
coordinates(HV_subsoilpH)<- ~ x + y
plot(HV_subsoilpH, add=T)


## Raster data extraction at points
DSM_data<- extract(hunterCovariates_sub,HV_subsoilpH, sp= 1, method = "simple")


## Export file to disk
DSM_data<- as.data.frame(DSM_data)
write.table(DSM_data, "hunterValley_SoilCovariates_pH.TXT", col.names=T, row.names=FALSE, sep=",") 

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
list.files(path = "C:/Users/bmalone/Dropbox/2017/DSM_workshopMaterials/testGrids", 
           pattern="\\.tif$", full.names=TRUE)



## GIS files on disk
files<- list.files(path = 
        "C:/Users/bmalone/Dropbox/2017/DSM_workshopMaterials/testGrids", 
        pattern="\\.tif$", full.names=TRUE)
files

#stack rasters
r1<- raster(files[1])
for(i in 2:length(files)){
  r1<- stack(r1,files[i])}
r1


## Raster data extraction at points
DSM_data<- extract(r1,HV_subsoilpH, sp= 1, method = "simple")


## Read data from file
hv.dat <- read.table("hunterValley_SoilCovariates_pH.TXT", sep = ",", header = T)
str(hv.dat)



## Statistical properties of target variable
library(fBasics)
library(nortest)
#skewness
sampleSKEW(hv.dat$pH60_100cm)

#kurtosis
sampleKURT(hv.dat$pH60_100cm)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
ad.test(hv.dat$pH60_100cm)

## Plotting
par(mfrow = c(1, 2))
hist(hv.dat$pH60_100cm)
qqnorm(hv.dat$pH60_100cm, plot.it = TRUE, pch = 4, cex = 0.7)
qqline(hv.dat$pH60_100cm, col = "red", lwd = 2)

## Map the target variable data spatially
library(ggplot2)
ggplot(hv.dat, aes(x = x, y = y)) + geom_point(aes(size = hv.dat$pH60_100cm))



## Mapping the spatial pattern of target variable (autocorrelation)
data(hunterCovariates_sub)

# Convert rasters to a data frame
tempD<-data.frame(cellNos=seq(1:ncell(hunterCovariates_sub)))
tempD$vals<- getValues(hunterCovariates_sub)
tempD<- tempD[complete.cases(tempD),]
cellNos<- c(tempD$cellNos)
gXY<- data.frame(xyFromCell(hunterCovariates_sub, cellNos, spatial=FALSE))
str(tempD)

## Inverse distance weighted interpolation
library(gstat)
IDW.pred <- idw(hv.dat$pH60_100cm ~ 1, locations = ~x + y, data = hv.dat,
newdata = gXY, idp = 2)

## Plot IDW map
IDW.raster.p <- rasterFromXYZ(as.data.frame(IDW.pred[, 1:3]))
plot(IDW.raster.p)

## Variogram modeling and kriging
vgm1 <- variogram(pH60_100cm ~ 1, ~x + y, hv.dat, width = 100, cutoff = 3000)
mod <- vgm(psill = var(hv.dat$pH60_100cm), "Exp", range = 3000, nugget = 0)
model_1 <- fit.variogram(vgm1, mod)
model_1

## Plot the variogram
plot(vgm1, model = model_1)

## Kriging
krig.pred <- krige(hv.dat$pH60_100cm ~ 1, locations = ~x + y, data = hv.dat, newdata = gXY, model = model_1)

## Plot kriging outputs
par(mfrow = c(2, 1))
krig.raster.p <- rasterFromXYZ(as.data.frame(krig.pred[, 1:3]))
krig.raster.var <- rasterFromXYZ(as.data.frame(krig.pred[, c(1:2, 4)]))
plot(krig.raster.p, main = "ordinary kriging predictions")
plot(krig.raster.var, main = "ordinary kriging variance")




## Correlation of target variable to covariates 
cor(hv.dat[, c("Terrain_Ruggedness_Index", "AACN", "Landsat_Band1", 
          "Elevation", "Hillshading", "Light_insolation",
          "Mid_Slope_Positon", "MRVBF", "NDVI", "TWI", "Slope"    )],
    hv.dat[,"pH60_100cm"])

