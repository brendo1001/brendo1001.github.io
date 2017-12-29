## R literacy: Part 7


##########################################################################################################################
## Linear models-the basics
## The lm function, model formulas, and statistical output

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
library(ithir)
data(USYD_soil1)
soil.data<- USYD_soil1
summary(cbind(clay=soil.data$clay, CEC=soil.data$CEC))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
plot(soil.data$clay, soil.data$CEC)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
mod.1<- lm(CEC~clay, data=soil.data, y=TRUE, x=TRUE)
mod.1

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
summary(mod.1)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
class(mod.1)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
mod.1$coefficients

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
coef(mod.1)
head(residuals(mod.1))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
names(summary(mod.1))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
summary(mod.1)[[4]]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
summary(mod.1)[["r.squared"]]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
head(predict(mod.1))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
plot(mod.1$y,mod.1$fitted.values, xlim= c(0,25), ylim=c(0,25))
abline(a = 0, b = 1, col="red")
## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
head(predict(mod.1, int="conf"))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
subs.soil.data<- soil.data[, c("clay", "CEC", "ExchNa", "ExchCa")]
summary(subs.soil.data)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
cor(na.omit(subs.soil.data))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
pairs(na.omit(subs.soil.data))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
mod.2<- lm(CEC~ clay + ExchNa + ExchCa, data= subs.soil.data)
summary(mod.2)






