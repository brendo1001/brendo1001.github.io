# ******************************************************************************
# *                                                                            
# *                           [Model evaluations]                                
# *                                                                            
# *  Description:                                                              
# * Some of the common goodness of fit measures are the 
# * root mean square error (RMSE), bias, 
# * coefficient of determination or commonly the R2 value, 
# * and concordance. This script looks at how these are used
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

## Goodness of fit and validation

library(ithir)
library(MASS)

#data
data(USYD_soil1)
soil.data<- USYD_soil1

#fit a basic linear model
mod.data <- na.omit(soil.data[, c("clay", "CEC")])
mod.1 <- lm(CEC ~ clay, data = mod.data, y = TRUE, x = TRUE)
mod.1

## goodness of fit
ithir::goof(observed = mod.data$CEC, predicted = mod.1$fitted.values, type = "DSM")


## Random subset to use a validation data set
set.seed(123)
training <- sample(nrow(mod.data), 0.7 * nrow(mod.data))
training

## fit model to calibration data
mod.rh <- lm(CEC ~ clay, data = mod.data[training, ], y = TRUE, x = TRUE)

## goodness of fit
ithir::goof(predicted = mod.rh$fitted.values, observed = mod.data$CEC[training])

## Validation
mod.rh.V <- predict(mod.rh, mod.data[-training, ])
ithir::(predicted = mod.rh.V, observed =mod.data$CEC[-training])

## Leave one out cross-validation
looPred <- numeric(nrow(mod.data))
for (i in 1:nrow(mod.data)) {
looModel <- lm(CEC ~ clay, data = mod.data[-i, ], y = TRUE, x = TRUE)
looPred[i] <- predict(looModel, newdata = mod.data[i, ])
}

## LOCV 
ithir::goof(predicted = looPred, observed =mod.data$CEC)


## END
