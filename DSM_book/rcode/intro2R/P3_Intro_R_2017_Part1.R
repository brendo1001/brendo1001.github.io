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
## Missing, indefinite, and infinnite values
x<- NA
x-2

is.na(x)
!is.na(x)
##########################################################################################################################


##########################################################################################################################
## Functions, arguments, and packages
sum(1,12.5,3.33,5,88)

a<- 1:10
b<- a
plot(x=a, y=b)

plot(a, b)
args(plot)

args(rnorm)

plot(rnorm(10,sqrt(mean(c(1:5, 7,1,8,sum(8.4,1.2,7))))),1:10)


#Install packages
install.packages("Cubist")
library(Cubist)

## Installation of the ithir package
library(devtools)
install_github("brendo1001/ithir_github/pkg")
library(ithir)

## detaching packages
detach("package:Cubist")
##########################################################################################################################


##########################################################################################################################
## Getting Help

?cubist

## global search of installed and not installed functions
??polygon

##
RSiteSearch("A Keyword")

##
apropos("mean")

