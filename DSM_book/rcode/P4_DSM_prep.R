# ******************************************************************************
# *                                                                            
# *                           [Preparatory and exploratory data analysis for digital soil mapping]                                
# *                                                                            
# *  Description:                                                              
# *  Some R codes very fundamental to doing digital soil mapping
# *       - Fitting spline depth functions to soil profile data
# *       - Intersecting point data with environmental covariate data
# *       - Some explorations and basic analysis of data prior to model fitting
# *                                                                            
# *  Created By:                                                               
# *  Brendan Malone                                                
# *                                                                            
# *  Last Modified:                                                            
# *  2023-09-11               
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
# *   McGarry, D., Ward, W.T., McBratney, A.B. (1989) Soil Studies in the Lower Namoi Valley: Methods and Data. The Edgeroi Data Set. (2 vols) (CSIRO Division of Soils: Adelaide).
# *   Malone, B.P., Hughes, P., McBratney, A.B., Minasny, B. (2014) A model for the identification of terrons in the Lower Hunter Valley, Australia. Geoderma Regional 1, 31-47.                                                                       
#
#
# *  The Data is provided "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
# *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
# *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    
# *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR      
# *  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,      
# *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA OR THE USE OR OTHER   
# *  DEALINGS IN THE DATA                                                                       
# ******************************************************************************
## libraries to load that will be used for the various tasks
library(ithir);library(gstat)
library(nortest);library(fBasics);library(ggplot2)
library(sf);library(terra)


#############################3
## Soil Depth Functions
# small data set from ithir
data(oneProfile)
str(oneProfile)

## Fit mass preserving spline
eaFit <- ithir::ea_spline(oneProfile, var.name="C.kg.m3.",
        d= t(c(0,5,15,30,60,100,200)),lam = 0.1, vlow=0, 
        show.progress=FALSE )
str(eaFit)

## Plot spline outputs
par(mfrow=c(3,1))
for (i in 1:3){
  ithir::plot_ea_spline(splineOuts=eaFit, d= t(c(0,5,15,30,60,100,200)),
  maxd=200, type=i, plot.which=1, label="carbon density")}

########################
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
# keep a record of the coordinates so they are not lost in the extraction process
HV_subsoilpH$x2<- HV_subsoilpH$x
HV_subsoilpH$y2<- HV_subsoilpH$y

#structure
str(HV_subsoilpH)

## raster data from the ithir package
hv.sub.rasters<- list.files(path = system.file("extdata/",package="ithir"),pattern = "hunterCovariates_sub",full.names = TRUE)
hv.sub.rasters<- rast(hv.sub.rasters)
hv.sub.rasters

## Basic plotting
## # plot raster
par(mfrow=c(1,1))
plot(hv.sub.rasters["Elevation"], main="Hunter Valley elevation map with overlayed point locations")

## ##plot points
HV_subsoilpH <- sf::st_as_sf(x = HV_subsoilpH,coords = c("x", "y"))
str(HV_subsoilpH)
plot(st_geometry(HV_subsoilpH), add=T, cex=0.5)

## Raster data extraction at points
DSM_data<- terra::extract(x = hv.sub.rasters, y = HV_subsoilpH, bind = T, method = "simple")
DSM_data<- as.data.frame(DSM_data)


#######
# Some basic statistical analyses of the soil data and covariates

# basic summary stats
round(summary(DSM_data$pH60_100cm),1)

#skewness
fBasics::sampleSKEW(DSM_data$pH60_100cm)

#kurtosis
fBasics::sampleKURT(DSM_data$pH60_100cm)

## Anderson-Darling test for normality
nortest::ad.test(DSM_data$pH60_100cm)

## Plotting
par(mfrow = c(1, 2))
hist(DSM_data$pH60_100cm)
qqnorm(DSM_data$pH60_100cm, plot.it = TRUE, pch = 4, cex = 0.7)
qqline(DSM_data$pH60_100cm, col = "red", lwd = 2)

## Map the target variable data spatially
par(mfrow = c(1, 1))
ggplot2::ggplot(DSM_data, aes(x = x2, y = y2)) + geom_point(aes(size = pH60_100cm))


## Mapping the spatial pattern of target variable (autocorrelation)
# Convert rasters to a data frame
tempD<-data.frame(cellNos=seq(1:ncell(hv.sub.rasters)))
tempD$vals<- terra::values(hv.sub.rasters)
tempD<- tempD[complete.cases(tempD),]
cellNos<- c(tempD$cellNos)
# xy coordinates of raster data 
gXY<- data.frame(terra::xyFromCell(hv.sub.rasters, cellNos))
names(gXY)<- c("x2", "y2")
str(tempD)

## Inverse distance weighted interpolation
IDW.pred <- gstat::idw(DSM_data$pH60_100cm ~ 1, locations = ~x2 + y2, data = DSM_data,
newdata = gXY, idp = 2)

## Plot IDW map
IDW.raster.p <- terra::rast(x = IDW.pred[,1:3], type = "xyz")
plot(IDW.raster.p)

## Variogram modeling and kriging
vgm1 <- gstat::variogram(pH60_100cm ~ 1, ~x2 + y2, DSM_data, width = 100, cutoff = 3000)
mod <- gstat::vgm(psill = var(DSM_data$pH60_100cm), "Exp", range = 3000, nugget = 0)
model_1 <- fit.variogram(vgm1, mod)
model_1

## Plot the variogram
plot(vgm1, model = model_1)

## Kriging
krig.pred <- gstat::krige(DSM_data$pH60_100cm ~ 1, locations = ~x2 + y2, data = DSM_data, newdata = gXY, model = model_1)

## Plot kriging outputs
par(mfrow = c(2, 1))
krig.raster.p <- terra::rast(x = krig.pred[,1:3], type = "xyz")
krig.raster.var <- terra::rast(x = krig.pred[,c(1,2,4)], type = "xyz")
plot(krig.raster.p, main = "ordinary kriging predictions")
plot(krig.raster.var, main = "ordinary kriging variance")


## Correlation of target variable to covariates 
cor(DSM_data[, c("Terrain_Ruggedness_Index", "AACN", "Landsat_Band1", 
          "Elevation", "Hillshading", "Light_insolation",
          "Mid_Slope_Positon", "MRVBF", "NDVI", "TWI", "Slope"    )],
    DSM_data[,"pH60_100cm"])

