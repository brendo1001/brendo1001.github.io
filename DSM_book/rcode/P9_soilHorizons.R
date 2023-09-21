# ******************************************************************************
# *                                                                            
# *                           [two-step DSM]                                
# *                                                                            
# *  Description:                                                              
##  Combining continuous and categorical modeling: Digital soil mapping of soil horizons and their depths
#
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
# *  2023-09-19             
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
# *   Malone, B. P., Minasny, B. & McBratney, A. B. (2017). 
# *   Using R for Digital Soil Mapping, Cham, Switzerland: Springer International Publishing. 
# *   https://doi.org/10.1007/978-3-319-44327-0#
#
# *  The Data is provided "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
# *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
# *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    
# *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR      
# *  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,      
# *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA OR THE USE OR OTHER   
# *  DEALINGS IN THE DATA                                                                       
# ******************************************************************************


#library
library(ithir)
library(sf);library(terra);library(aqp)
library(nnet);library(MASS);library(quantregForest)

#data (download from wesite)
load("/home/brendo1001/mystuff/devs/site_source/DSM_book/data/twoStep/HV_horizons.rda")
dat$A1<- as.factor(dat$A1)
summary(dat$A1)
str(dat)
dat$A1[dat$A1d <= 15] <- 0


#convert point to spatial object
dat<- sf::st_as_sf(x = dat,coords = c("e", "n"))

#covariates
# grids (covariate rasters from ithir package)
hv.rasters <- list.files(path = system.file("extdata/", package = "ithir"), pattern = "hunterCovariates_A", full.names = T)
hv.rasters

# read them into R as SpatRaster objects
hv.rasters <- terra::rast(hv.rasters)
## raster properties
hv.rasters
plot(hv.rasters)
names(hv.rasters)

## Overlay points onto raster
plot(hv.rasters[[2]])
points(dat,pch=20)

#Covariate extract for points
ext<- terra::extract(x = hv.rasters, y = dat, bind = T, method = "simple")
dsm.dat<- as.data.frame(ext)

#remove sites with missing covariates
names(dsm.dat)
dsm.dat<- dsm.dat[complete.cases(dsm.dat[,24:31]),]

## Set target variable and subset data for validation
#A1 Horizon
dsm.dat$A1<- as.factor(dsm.dat$A1)
#random subset
set.seed(123)
training <- sample( nrow(dsm.dat), 0.75 *nrow(dsm.dat)) 
#calibration dataset
dsm.cal<- dsm.dat[training,] 
#validation dataset
dsm.val<- dsm.dat[-training,] 

## Presence/absence model
# A1 presence or absence model
mn1<- multinom(formula = A1 ~ hunterCovariates_A_AACN + hunterCovariates_A_elevation + hunterCovariates_A_Hillshading +   
               hunterCovariates_A_light_insolation + hunterCovariates_A_MRVBF +          
               hunterCovariates_A_Slope + hunterCovariates_A_TRI + hunterCovariates_A_TWI ,
                data = dsm.cal)
#stepwise variable selection
mn2<- stepAIC(mn1,direction="both", trace=FALSE)
summary(mn2)

## Goodness of fit
#calibration
mod.pred<-predict(mn2, newdata = dsm.cal,type="class")
goofcat(observed = dsm.cal$A1,predicted = mod.pred)

#validation
val.pred<-predict(mn2, newdata = dsm.val,type="class")
goofcat(observed = dsm.val$A1,predicted = val.pred)

## Model of horizon depth
#Remove missing values
#calibration
mod.dat <- dsm.cal[!is.na(dsm.cal$A1d),]  

#validation
val.dat <- dsm.val[!is.na(dsm.val$A1d),] 

#Fit quantile regression forest
qrf <- quantregForest(x=mod.dat[,24:31], y=mod.dat$A1d, importance=TRUE)

## Goodness of fit
## Calibration
quant.cal  <- predict(qrf, newdata= mod.dat[,24:31], all=T)
goof(observed = mod.dat$A1d, predicted = quant.cal[,2], plot.it = T)

#Validation
quant.val  <- predict(qrf, newdata= val.dat[,24:31], all=T)
goof(observed = val.dat$A1d, predicted = quant.val[,2], plot.it = T)

#PICP
sum(quant.val[,1]<=val.dat$A1d & quant.val[,2]>=val.dat$A1d)/nrow(val.dat)


## Plotting
pred.profs<- read.table(file="/home/brendo1001/mystuff/devs/site_source/DSM_book/data/twoStep/validation_outs.txt", sep = ",",header = T)
obs.profs<- read.table(file="/home/brendo1001/mystuff/devs/site_source/DSM_book/data/twoStep/validation_obs.txt", sep = ",",header= T)


#Validation data horizon observations (1st 3 rows)
obs.profs[1:3,c(1,4:14)]

#Associated model predictions (1st 3 rows)
pred.profs[1:3,1:12]

#matched soil profiles
sum(obs.profs$A1==pred.profs$a1 & obs.profs$A2==pred.profs$a2 & obs.profs$AP==pred.profs$ap & obs.profs$B1==pred.profs$b1 &
  obs.profs$B21==pred.profs$b21 & obs.profs$B22==pred.profs$b22 & obs.profs$B23==pred.profs$b23 & obs.profs$B24==pred.profs$b24 &
  obs.profs$B3==pred.profs$b3 & obs.profs$BC==pred.profs$bc & obs.profs$C==pred.profs$c)/nrow(obs.profs)

#Subset of matching data (observations)
match.dat<- obs.profs[which(obs.profs$A1==pred.profs$a1 & obs.profs$A2==pred.profs$a2 & obs.profs$AP==pred.profs$ap & obs.profs$B1==pred.profs$b1 & obs.profs$B21==pred.profs$b21 & obs.profs$B22==pred.profs$b22 & obs.profs$B23==pred.profs$b23 & obs.profs$B24==pred.profs$b24 & obs.profs$B3==pred.profs$b3 & obs.profs$BC==pred.profs$bc & obs.profs$C==pred.profs$c),]

#Subset of matching data (predictions)
match.dat.P<- pred.profs[which(obs.profs$A1==pred.profs$a1 & obs.profs$A2==pred.profs$a2 & obs.profs$AP==pred.profs$ap & obs.profs$B1==pred.profs$b1 & obs.profs$B21==pred.profs$b21 & obs.profs$B22==pred.profs$b22 & obs.profs$B23==pred.profs$b23 & obs.profs$B24==pred.profs$b24 & obs.profs$B3==pred.profs$b3 & obs.profs$BC==pred.profs$bc & obs.profs$C==pred.profs$c),]

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
## Apply A1 horizon presence/absence model spatially
A1.class<-terra::predict(object = hv.rasters, model = mn2)
A1.class
plot(A1.class, main = "A1-horizon occurence")

#Apply A1 horizon depth model spatially
# get covariates into a table
tempD <- data.frame(cellNos = seq(1:terra::ncell(hv.rasters)))
vals <- as.data.frame(terra::values(hv.rasters))
tempD <- cbind(tempD, vals)
tempD <- tempD[complete.cases(tempD), ]
cellNos <- c(tempD$cellNos)
gXY <- data.frame(terra::xyFromCell(hv.rasters, cellNos))
tempD <- cbind(gXY, tempD)
str(tempD)

# extend model to covariates
A1.depth<-predict(newdata= tempD, object = qrf)
# append coordinates
A1.depth.map<- cbind(data.frame(tempD[, c("x", "y")]), A1.depth)
# create raster
A1.depth.map <- terra::rast(x = A1.depth.map[,c(1,2,4)], type = "xyz")
plot(A1.depth.map, main = "A1-horizon thickness (unmasked)")

#Mask out areas where horizon is absent
msk <- terra::ifel(A1.class != 1, NA, 1)
plot(msk)
A1.depth.masked <- terra::mask(A1.depth.map, msk, inverse =T)
plot(A1.depth.masked, main = "A1-horizon thickness (masked)")
##END

