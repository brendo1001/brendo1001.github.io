# ******************************************************************************
# *                                                                            
# *                           [Cross-validation strategies]                                
# *                                                                            
# *  Description:                                                              
# *  Different model cross validation strategies:
# *  random holdback, leave-one-out, k-fold, bootstrap
# * 
# * 
# *       
# *       
# *       
# *                                                                            
# *  Created By:                                                               
# *  Brendan Malone                                                
# *                                                                            
# *  Last Modified:                                                            
# *  2023-09-112              
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

# libraries and data
library(ithir)
library(MASS)
data(USYD_soil1)
soil.data <- USYD_soil1
mod.data <- na.omit(soil.data[, c("clay", "CEC")])

## leave-one- out cross-validation
looPred <- numeric(nrow(mod.data))
for (i in 1:nrow(mod.data)) {
  looModel <- lm(CEC ~ clay, data = mod.data[-i, ], y = TRUE, x = TRUE)
  looPred[i] <- predict(looModel, newdata = mod.data[i, ])
}

# evaluation
ithir::goof(predicted = looPred, observed =mod.data$CEC, plot.it = T)


## Random holdback
# select a sample of given proportion of total dataset size
set.seed(123)
training <- sample(nrow(mod.data), 0.7 * nrow(mod.data),replace = FALSE)

# fit model
mod.rh <- lm(CEC ~ clay, data = mod.data[training, ], y = TRUE, x = TRUE)

# evaluate model on calibration data
ithir::goof(predicted = mod.rh$fitted.values, observed = mod.data$CEC[training], plot.it = T)

# evaluate model on out-of-bag data
mod.rh.V <- predict(mod.rh, mod.data[-training, ])
ithir::goof(predicted = mod.rh.V, observed = mod.data$CEC[-training], plot.it = T)

## Repeated random hold-back
# place to store results
validation.outs<- matrix(NA, nrow=5, ncol =6)

# repeat subsetting and model fitting
for(i in 1:5){
  training <- sample(nrow(mod.data), 0.7 * nrow(mod.data), replace = FALSE)
  mod.rh <- lm(CEC ~ clay, data = mod.data[training, ], y = TRUE, x = TRUE)
  mod.rh.V <- predict(mod.rh, mod.data[-training, ])
  validation.outs[i,1]<- i
  validation.outs[i,2:6]<- as.matrix(goof(predicted = mod.rh.V, observed =mod.data$CEC[-training]))}

validation.outs<- as.data.frame(validation.outs)
names(validation.outs)<- c("iteration", "R2", "concordance", "MSE", "RMSE", "bias")

# print outputs
validation.outs

## k-fold cross-validation
# Set up matrix to store goodness of fit statistics
# for each model
# 4 fold repeated 1000 times = 4000 models
validation.outs<- matrix(NA, nrow=4000, ncol =6)

# repeat subsetting and model fitting
cnt<- 1
for (j in 1:1000){
  # set up folds
  folds<- rep(1:4,length.out=nrow(mod.data))
  # random permutation
  rs<- sample(1:nrow(mod.data),replace = F)
  rs.folds<- folds[order(rs)]
  
  # model fitting for each combination of folds
  for(i in 1:4){
    training <- which(rs.folds != i)
    mod.rh <- lm(CEC ~ clay, data = mod.data[training, ], y = TRUE, x = TRUE)
    mod.rh.V <- predict(mod.rh, mod.data[-training, ])
    validation.outs[cnt,1]<- cnt
    validation.outs[cnt,2:6]<- as.matrix(goof(predicted = mod.rh.V, observed =mod.data$CEC[-training]))
    cnt<- cnt + 1}}

# make the evaluation table a bit easier to decipher
validation.outs<- as.data.frame(validation.outs)
names(validation.outs)<- c("iteration", "R2", "concordance", "MSE", "RMSE", "bias")

# averaged goodness of fit measures
apply(validation.outs[,2:6], 2, mean)
# standard deviation of goodness of fit measures
apply(validation.outs[,2:6], 2, sd)

## Bootstrapping
# Set up matrix to store goodness of fit statistics
# for each model of the 4000 models
validation.outs<- matrix(NA, nrow=4000, ncol =6)

# repeat subsetting and model fitting
for (j in 1:4000){
  # sample with replacement
  rs<- sample(1:nrow(mod.data),replace = T)
  # get the unique cases
  urs<- unique(rs)
  # calibration data
  cal.dat<- mod.data[urs,]
  #validation data
  val.dat<- mod.data[-urs,]
  
  # model fitting 
  mod.rh <- lm(CEC ~ clay, data = cal.dat, y = TRUE, x = TRUE)
  mod.rh.V <- predict(mod.rh, val.dat)
  validation.outs[j,1]<- j
  validation.outs[j,2:6]<- as.matrix(goof(predicted = mod.rh.V, observed =val.dat$CEC))}

validation.outs<- as.data.frame(validation.outs)
names(validation.outs)<- c("iteration", "R2", "concordance", "MSE", "RMSE", "bias")

# averaged goodness of fit meansures
apply(validation.outs[,2:6], 2, mean)
# standard deviation of goodness of fit meansures
apply(validation.outs[,2:6], 2, sd)



## END
