## R literacy: Part 4


##########################################################################################################################
## Graphics: the basics
## Introduction to the plot function

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
z<- rnorm(10)
plot (z)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
x<- -15:15
y<- x^2
plot(x,y)

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
plot(x,y, type="o", xlim=c(-20,20), ylim=c(-10,300),
      pch=21, col="red", bg="yellow",
      xlab="The X variable", ylab="X squared")

## ----echo=TRUE, tidy=TRUE,cache=FALSE,eval=FALSE, background='white'-----
plot(1:25, rep(1,25), pch=1:25, ylim=c(0,10), xlab="", ylab="", axes=FALSE)
text(1:25, 1.8, as.character(1:25), cex=0.7)
text(12.5, 2.5, "Default", cex=0.9)
points(1:25, rep(4,25), pch=1:25, col= "blue")
text(1:25, 4.8, as.character(1:25), cex=0.7, col="blue")
text(12.5, 5.5, "Blue", cex=0.9, col="blue")
points(1:25, rep(7,25), pch=1:25, col= "blue", bg="red")
text(1:25, 7.8, as.character(1:25), cex=0.7, col="blue")
text(10, 8.5, "Blue", cex=0.9, col="blue")
text(15, 8.5, "Red", cex=0.9, col="red")
box()

