## Goodness of fit and validation

library(ithir)
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
goof(observed = mod.data$CEC, predicted = mod.1$fitted.values, 
     type = "DSM")


## Random subset to use a validation data set
set.seed(123)
training <- sample(nrow(mod.data), 0.7 * nrow(mod.data))
training

## fit model to calibration data
mod.rh <- lm(CEC ~ clay, data = mod.data[training, ], y = TRUE, x = TRUE)

## goodness of fit
goof(predicted = mod.rh$fitted.values, observed = mod.data$CEC[training])

## Validation
mod.rh.V <- predict(mod.rh, mod.data[-training, ])
goof(predicted = mod.rh.V, observed =mod.data$CEC[-training])

## Leave one out cross-validation
looPred <- numeric(nrow(mod.data))
for (i in 1:nrow(mod.data)) {
looModel <- lm(CEC ~ clay, data = mod.data[-i, ], y = TRUE, x = TRUE)
looPred[i] <- predict(looModel, newdata = mod.data[i, ])
}

## LOCV 
goof(predicted = looPred, observed =mod.data$CEC)


## END
