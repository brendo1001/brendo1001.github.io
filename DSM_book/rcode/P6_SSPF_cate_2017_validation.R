## Categorical soil attribute modeling
## Validation goodness of fit measures for categorical data


library(ithir)


## Create a toy dataset
con.mat <- matrix(c(5, 0, 1, 2, 0, 15, 0, 5, 0, 1, 31, 0, 0, 10, 2, 11), nrow = 4, ncol = 4)
rownames(con.mat) <- c("DE", "VE", "CH", "KU")
colnames(con.mat) <- c("DE", "VE", "CH", "KU")
con.mat

## column sums
colSums(con.mat)

## row sums
rowSums(con.mat)

## Overall accuracy
ceiling(sum(diag(con.mat))/sum(colSums(con.mat)) * 100)

## Producer's accuracy
ceiling(diag(con.mat)/colSums(con.mat) * 100)

## User's accuracy
ceiling(diag(con.mat)/rowSums(con.mat) * 100)

## goodness of fit
goofcat(conf.mat = con.mat, imp=TRUE)

