## R literacy: Part 6


##########################################################################################################################
## Exploratory data analysis
## Summary statistics

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
library(ithir)
data(USYD_soil1)
soil.data<- USYD_soil1
names(soil.data)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
mean(soil.data$clay, na.rm=TRUE)
median(soil.data$clay, na.rm=TRUE)
sd(soil.data$clay, na.rm=TRUE)
var(soil.data$clay, na.rm=TRUE)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
summary(soil.data[,1:6])
##########################################################################################################################



##########################################################################################################################
## Histograms and boxplots

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
hist(soil.data$clay)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
boxplot(soil.data$clay)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
boxplot(Total_Carbon~Landclass, data=soil.data)
##########################################################################################################################



##########################################################################################################################
## Normal quantile and cumulative probability plots

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
qqnorm(soil.data$Total_Carbon, plot.it=TRUE, pch=4, cex=0.7)
qqline(soil.data$Total_Carbon,col="red", lwd=2)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
qqnorm(log(soil.data$Total_Carbon), plot.it=TRUE, pch=4, cex=0.7)
qqline(log(soil.data$Total_Carbon),col="red", lwd=2)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
quantile(soil.data$Total_Carbon, na.rm=TRUE)
quantile(soil.data$Total_Carbon, na.rm=TRUE, probs=seq(0,1,0.05))
quantile(soil.data$Total_Carbon, na.rm=TRUE, probs=seq(0.9,1,0.01))

