# ******************************************************************************
# *                                                                            
# *                           [categorical soil attribute modeling]                                
# *                                                                            
# *  Description:                                                              
##  Validation goodness of fit measures for categorical data
#
#
# * 
# *       
# *       
# *       
# *                                                                            
# *  Created By:                                                               
# *  Brendan Malone                                                
# *                                                                            
# *  Last Modified:                                                            
# *  2023-09-19             
# *                                                                            
# *  License:   
# *     Data Usage License (Data-UL)                                             
# *                                                                            
# *   Permission is hereby granted, free of charge, to any person obtaining a    
# *   copy of this data and associated code files (the "Data"), to use the Data  
# *   for any lawful purpose, including but not limited to analysis, research,   
# *   and reporting, without modification of the original Data or sharing any   
# *   modified versions of the Data.      
#
# *   Users of the Data must provide proper attribution to the original source   
# *   of the Data in any publication, research, or derivative works by including 
# *   the following attribution:  
# *
# *   Malone, B. P., Minasny, B. & McBratney, A. B. (2017). 
# *   Using R for Digital Soil Mapping, Cham, Switzerland: Springer International Publishing. 
# *   https://doi.org/10.1007/978-3-319-44327-0#
#
# *  The Data is provided "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
# *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
# *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    
# *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR      
# *  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,      
# *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA OR THE USE OR OTHER   
# *  DEALINGS IN THE DATA                                                                       
# ******************************************************************************


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

# END

