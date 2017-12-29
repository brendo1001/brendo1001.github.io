## R literacy: Part 5


##########################################################################################################################
## Manipulating data
## Modes, classes, attributes, length, and coercion



## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- 1:10
mode(x)
length(x)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- 1:10
as.character(x)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
X<- matrix(1:30,nrow=3)
as.data.frame(X)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
X<- matrix(1:30, nrow=3)
X
nrow(X)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
ncol(X)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
dim(X)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- 1:10
NROW(x)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
length(X)
length(x)
##########################################################################################################################

##########################################################################################################################
## Indexing, sub-setting, sorting and locating data

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
v1<- c(5,1,3,8)
v1
v1[3]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
v1[1:3]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
v1[-4]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
v1[v1<5]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
v1 < 5
v1[c(FALSE,TRUE,TRUE,FALSE)]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
length(v1)
v1[8]<- 10
length(v1)
v1

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
library(ithir)
data(USYD_soil1)
soil.data<- USYD_soil1
dim(soil.data)
str(soil.data)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data[1:5,1:2]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data[1:2,]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data[1:5, "Total_Carbon"]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data[1:5, c("Total_Carbon", "CEC")]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
na.omit(soil.data[soil.data$ESP>10,])

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
subset(soil.data, ESP>10)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
subset(soil.data, ESP>10 & Lower.Depth > 0.3 )

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
## subset(soil.data, Landclass=="Forest" | Landclass=="native pasture" )

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
head(subset(soil.data, Landclass %in% c("Forest", "native pasture")))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
X<- matrix(1:30, nrow=3)
X
X[3,8]
X[,3]
Y<- array(1:90, dim=c(3,10,3))
Y[3,1,1]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
list.1<- list(1:10, X, Y)
list.1[[1]]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
list.1[[2]][3,2]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
soil.data.split<- split(soil.data, soil.data$PROFILE)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- rnorm(5)
x
y<- sort(x)
y

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
head(soil.data[order(soil.data$clay),])

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
order(soil.data$clay)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
match(c(25.85,11.45,9.23), soil.data$CEC)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data[c(41,59,18),]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
match(max(soil.data$CEC, na.rm=TRUE), soil.data$CEC)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data$CEC[95]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
which(soil.data$ESP>5)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
which(soil.data$ESP>5 & soil.data$clay > 30)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
which(is.na(soil.data$ESP))
soil.data$ESP[c(which(is.na(soil.data$ESP)))]
##########################################################################################################################



##########################################################################################################################
## Factors
## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
a<- c(rep(0,4),rep(1,4))
a
a<- factor(a)
a

## ----echo=TRUE, tidy= TRUE,cache=FALSE,eval=TRUE, background='white'-----
soil.drainage<- c("well drained", "imperfectly drained", 
                  "poorly drained", "poorly drained", 
                  "well drained", "poorly drained")

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.drainage1<- factor(soil.drainage)
soil.drainage1
as.numeric(soil.drainage1)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.drainage2<- factor(soil.drainage, levels= c("well drained", 
                  "imperfectly drained", "poorly drained"))
as.numeric(soil.drainage2)
##########################################################################################################################

##########################################################################################################################
## Combining data

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.info1<- data.frame(soil=c("Vertosol", "Hydrosol", "Sodosol"), response=1:3)
soil.info1
soil.info2<- data.frame(soil=c("Chromosol", "Dermosol", "Tenosol"), response=4:6)
soil.info2
soil.info<- rbind(soil.info1, soil.info2)
soil.info
a.column<- c(2.5,3.2,1.2,2.1,2,0.5)
soil.info3<- cbind(soil.info, SOC=a.column)
soil.info3

