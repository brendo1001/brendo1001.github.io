## Decision tree modelling for the creation of digital soil maps


library(ithir)
library(raster)
library(rgdal)
library(sp)

#point data
data(HV_subsoilpH)

# Start afresh 
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


#grids (covariate raster)
data(hunterCovariates_sub)

## make data a sptatial object
coordinates(HV_subsoilpH)<- ~ x + y

# covariate data extract
DSM_data<- extract(hunterCovariates_sub, HV_subsoilpH, sp= 1, method = "simple")
DSM_data<- as.data.frame(DSM_data)
str(DSM_data)

## remove any missing values
which(!complete.cases(DSM_data))
DSM_data<- DSM_data[complete.cases(DSM_data),]

## Fitting a decsion tree model
library(rpart)
set.seed(123)
training <- sample(nrow(DSM_data), 0.70 * nrow(DSM_data)) #random holdback
hv.RT.Exp <- rpart(pH60_100cm ~ AACN + 
              Landsat_Band1 + Elevation + Hillshading + 
              Mid_Slope_Positon + MRVBF + NDVI + 
              TWI, data = DSM_data[training, ], 
              control = rpart.control(minsplit = 50))

## model summary
summary(hv.RT.Exp)
printcp(hv.RT.Exp)

plot(hv.RT.Exp)
text(hv.RT.Exp)

##Goodness of fit
#Internal validation
RT.pred.C <- predict(hv.RT.Exp, DSM_data[training, ])
goof(observed = DSM_data$pH60_100cm[training], predicted = RT.pred.C )

#External validation
RT.pred.V <- predict(hv.RT.Exp, DSM_data[-training, ])
goof(observed = DSM_data$pH60_100cm[-training], predicted = RT.pred.V )


## Create the map
map.RT.r1<- predict(hunterCovariates_sub, hv.RT.Exp,
                     "soilpH_60_100_RT.tif",format = "GTiff",
                     datatype = "FLT4S", overwrite = TRUE  )

 
plot(map.RT.r1, main = "Decision tree predicted Hunter Valley soil pH (60-100cm")

## END

