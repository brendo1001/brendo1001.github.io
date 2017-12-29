## R literacy: Part 2


##########################################################################################################################
## Vectors, matrices, and arrays
## Creating and working with vectors


## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
1:5

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
seq(-10, 10,2)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
rep(4,5)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
c(2,1,5,100,2)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
c(a=2,b=1,c=5,d=100,e=2)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
v1<- c(2,1,5,100,2)
v1

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
probably.not_a.good_example.for.a.name.100<- seq(1,2,0.1)
probably.not_a.good_example.for.a.name.100

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- rep(1:3)
y<- 4:10
z<- c(x,y)
z

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- 1:10
x > 5

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
a<- x > 5
a
a * 1.4

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
paste("A", "B","C","D",TRUE, 42)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
month<- "April"
day<- 29
year<- 1770
paste("Captain Cook, on the ",
      day,"th day of ",month,", ", year
      , ", sailed into Botany Bay", sep="")

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
group<- 1:10
id<- LETTERS[1:10]
for(i in 1:10){
  print(paste("group =", group[i], "id =", id[i]))
}
##########################################################################################################################


##########################################################################################################################
## Vector arithmetic, some common functions and vectorised formats

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- 6:10
x
x+2

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
y<- c(4,3,7,1,1)
y
z<- x + y
z

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
x<- 1:10
m<- 0.8
b<- 2
y<- m * x + b
y

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, warning=TRUE, background='white'----
x<- 1:10
m<- 0.8
b<- c(2,1,1)
y<- m * x + b
y

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
pi

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, warning=TRUE, background='white'----
7 - 2 * 4

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, warning=TRUE, background='white'----
(7-2) * 4 

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, warning=TRUE, background='white'----
10^1:5

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, warning=TRUE, background='white'----
10^(1:5)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, warning=TRUE, background='white'----
x<- 1:10
sqrt(x)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, warning=TRUE, background='white'----
sqrt(1:10)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, warning=TRUE, background='white'----
sqrt(c(1,2,3,4,5,6,7,8,9,10))

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, error=TRUE, background='white'----
sqrt(1,2,3,4,5,6,7,8,9,10)
##########################################################################################################################

##########################################################################################################################
## Matrices and arrays

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
X<- matrix(1:15, nrow= 5, ncol=3)
X

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
as.vector(X)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
X<- matrix(1:15, nrow= 5, ncol=3, byrow=T)
X

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
Y<- array(1:30, dim= c(5,3,2))
Y

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'------
Z<- matrix (1, nrow=5, ncol=3)
Z
X + Z

## ERROR! Dimensions do not match
Z<- matrix (1, nrow=3, ncol=3)
X + Z

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white', error=TRUE----
Z
x<- 1:9
Z + x
y<- 1:3
Z + y

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white', error=TRUE----
X<- matrix(c(1,2.5,6,7.5,4.9,5.6,9.9,7.8,9.3), nrow=3)
X
solve(X)

## ----echo=FALSE, tidy=TRUE,cache=FALSE,eval=TRUE, background='white'-----
X<- matrix(1:25, nrow= 5, ncol=5, byrow=T)
X

