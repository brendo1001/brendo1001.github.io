## R literacy: Part 3


##########################################################################################################################
## Data frames, data import, and data export


## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
dat<- data.frame(profile_id= c("Chromosol","Vertosol","Sodosol"),
      FID=c("a1","a10","a11"), easting=c(337859, 344059,347034), 
      northing=c(6372415,6376715,6372740), visted=c(TRUE, FALSE, TRUE))
dat

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
str(dat)

##########################################################################################################################


##########################################################################################################################
## Reading data from files

## ----ERROR!-----
soil.data<- read.table("USYD_soil1.txt", header=TRUE, sep=",")
str(soil.data)
head(soil.data)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
library(ithir)
data(USYD_soil1)
soil.data<- USYD_soil1
str(soil.data)
head(soil.data)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
which(is.na(soil.data$CEC))
soil.data[8:11,]

## ----May not work-----
soil.data<- edit(soil.data)
##########################################################################################################################


##########################################################################################################################
## Creating data frames manually

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil<- c("Chromosol", "Vertosol", "Organosol", "Anthroposol")
carbon<- c(2.1, 2.9, 5.5, 0.2)
dat<- data.frame(soil.type=soil, soil.OC=carbon)
dat

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
names(dat)<- c("soil","SOC")
dat

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
dat<- data.frame(soil.type=soil, soil.OC=carbon, 
      row.names=c("Ch","Ve","Or","An"))
dat
##########################################################################################################################
## 


##########################################################################################################################
## Working with data frames

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
names(soil.data)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data$ESP

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
mean(soil.data$ESP)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
mean(na.omit(soil.data$ESP))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
attach(soil.data)
ESP

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white', error=TRUE----
## ## This will throw an error
detach(soil.data)
ESP

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
## soil.data[,10]

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data$Upper<- soil.data$Upper.Depth*100
soil.data$Lower<- soil.data$Lower.Depth*100
head(soil.data)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
soil.data$ESP
na.omit(soil.data$ESP)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
## soil.data.cleaned<- na.omit(soil.data)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
is.na(soil.data$ESP)
##########################################################################################################################
## 


##########################################################################################################################
## Writing data to file

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
 write.table(soil.data, file= "file name.txt",
             col.names=TRUE, row.names=FALSE, sep="\t")

