## R literacy: Part 1


##########################################################################################################################
## R basics: commands, expressions, assignments, operators, objects

## Add two numbers together
1+1

## assignent
x<-1+1
x

## Not the same
x< -1+1

## assignment 
x<-   1

## list objects
ls()

## remove objects
rm(x)
x

## multiple assignments to one value
x<-y<-z<- 1.0
ls()

## R is case sensitive
x<- 1+1
x
X

## commands can be multi-line
x<- 
+  1+1
##########################################################################################################################


##########################################################################################################################
### R Data Types


## Numeric
x<- 10.2
x

## Character
name<- "John Doe"
name

## ERROR!
name<- John


## Logical
a<- TRUE
a

## Logical
4 < 2

## logical
b<- 4 < 2
b

## complex number
cnum1<- 10 + 3i
cnum1

## figure out the class of things
class(name)
class(a)
class(x)
mode(x)
##########################################################################################################################


##########################################################################################################################
## R data structures

## vector
x<- 1:12
x

## matrix
X<- matrix(1:12, nrow=3)
X

## array
Y<- array(1:30,dim=c(2,5,3))
Y

## data frame
dat<- (data.frame(profile_id= c("Chromosol","Vertosol","Sodosol"),
      FID=c("a1","a10","a11"), easting=c(337859, 344059,347034), 
      northing=c(6372415,6376715,6372740), visited=c(TRUE, FALSE, TRUE)))
dat

## list
summary.1<- list(1.2, x,Y,dat)
summary.1

## null
x<- NULL
##########################################################################################################################


##########################################################################################################################
## Missing, inde???nite, and in???nite values

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- NA
x-2

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
is.na(x)
!is.na(x)
##########################################################################################################################


##########################################################################################################################
## Functions, arguments, and packages

## ----echo=TRUE, tidy=TRUE,cache=FALSE, background='white'----------------
sum(1,12.5,3.33,5,88)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
a<- 1:10
b<- a
plot(x=a, y=b)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
plot(a, b)

## ----echo=TRUE, tidy=TRUE,cache=FALSE, background='white'----------------
args(plot)

## ----echo=TRUE, tidy=TRUE,cache=FALSE, background='white'----------------
args(rnorm)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
plot(rnorm(10,sqrt(mean(c(1:5, 7,1,8,sum(8.4,1.2,7))))),1:10)


## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
install.packages("Cubist")

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
library(Cubist)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
library(devtools)
install_bitbucket("brendo1001/ithir/pkg")
library(ithir)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
detach("package:Cubist")
##########################################################################################################################


##########################################################################################################################
## Getting Help

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
?cubist

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
??polygon

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
RSiteSearch("A Keyword")

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
apropos("mean")

