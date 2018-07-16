## Digital soil assessment: A simple enterprise suitability example.


#HAZELNUT SUITABILITY ASSESSMENT FUNCTION
hazelnutSuits<- function(samp.matrix){
  out.matrix<- matrix(NA, nrow=nrow(samp.matrix),ncol=10) #ten selection variable for hazelnuts
  
  # Chill Hours
  out.matrix[which(samp.matrix[,1]>1200),1]<- 1
  out.matrix[which(samp.matrix[,1] >600 & samp.matrix[,1] <=1200),1]<- 2
  out.matrix[which(samp.matrix[,1] <=600),1]<- 4
  
  # Clay content
  out.matrix[which(samp.matrix[,2]> 10 & samp.matrix[,2] <=30),2]<- 1
  out.matrix[which(samp.matrix[,2]>30 & samp.matrix[,2] <=50),2]<- 2
  out.matrix[which(samp.matrix[,2]>50 | samp.matrix[,2] <=10),2]<- 4
  
  # Soil Drainage
  out.matrix[which(samp.matrix[,3] > 3.5),3]<- 1
  out.matrix[which(samp.matrix[,3]<= 3.5 & samp.matrix[,3] > 2.5 ),3]<- 2
  out.matrix[which(samp.matrix[,3]<= 2.5 & samp.matrix[,3] > 1.5 ),3]<- 3
  out.matrix[which(samp.matrix[,3] <= 1.5),3]<- 1
  
  # EC (transformed variable)
  out.matrix[which(samp.matrix[,4] <= 0.15),4]<- 1
  out.matrix[which(samp.matrix[,4] > 0.15),4]<- 4
  
  # Frost
  out.matrix[which(samp.matrix[,10] == 0),5]<- 1
  out.matrix[which(samp.matrix[,10] != 0 & samp.matrix[,5] >= 80),5]<- 1
  out.matrix[which(samp.matrix[,10] != 0 & samp.matrix[,5] < 80 & samp.matrix[,5] >= 60),5]<- 2
  out.matrix[which(samp.matrix[,10] != 0 & samp.matrix[,5] < 60 & samp.matrix[,5] >= 40),5]<- 3
  out.matrix[which(samp.matrix[,10] != 0 & samp.matrix[,5] < 40),5]<- 3
  
  # pH
  out.matrix[which(samp.matrix[,6] <=6.5 & samp.matrix[,6] >=5.5 ),6]<- 1
  out.matrix[which(samp.matrix[,6] >6.5 & samp.matrix[,6] <=7.1 ),6]<- 3
  out.matrix[which(samp.matrix[,6] < 5.5 | samp.matrix[,6] >7.1 ),6]<- 4
  
  #rainfall
  out.matrix[which(samp.matrix[,7] <=50),7]<- 1
  out.matrix[which(samp.matrix[,7] > 50),7]<- 4
  
  
  #soil depth
  out.matrix[which(samp.matrix[,13] == 0),8]<- 1
  out.matrix[which(samp.matrix[,13] != 0 & samp.matrix[,8] > 50),8]<- 1
  out.matrix[which(samp.matrix[,13] != 0 & samp.matrix[,8] <= 50 & samp.matrix[,8] > 40),8]<- 2
  out.matrix[which(samp.matrix[,13] != 0 & samp.matrix[,8] <= 40 & samp.matrix[,8] > 30),8]<- 3
  out.matrix[which(samp.matrix[,13] != 0 & samp.matrix[,8] <= 30),8]<- 4
  
  # temperature
  out.matrix[which(samp.matrix[,9] >20 & samp.matrix[,9] <=30 ),9]<- 1
  out.matrix[which(samp.matrix[,9] >30 & samp.matrix[,9] <=33 | samp.matrix[,9] <=20 & samp.matrix[,9] >18 ),9]<- 2
  out.matrix[which(samp.matrix[,9] >33 & samp.matrix[,9] <=35 ),9]<- 3
  out.matrix[which(samp.matrix[,9] >35 | samp.matrix[,9] <=18),9]<- 4
  
  # rocks
  out.matrix[which(samp.matrix[,11] == 0),10]<- 1
  out.matrix[which(samp.matrix[,11] != 0 & samp.matrix[,12] <= 2),10]<- 1
  out.matrix[which(samp.matrix[,11] != 0 & samp.matrix[,12] == 3),10]<- 2
  out.matrix[which(samp.matrix[,11] != 0 & samp.matrix[,12] == 4),10]<- 3
  out.matrix[which(samp.matrix[,11] != 0 & samp.matrix[,12] > 4),10]<- 4
  return(out.matrix)}



## Data for the exercise
load(file="lsa_inputs.rda")


#LSA input variables
library(raster)
names(lsa.variables)
class(lsa.variables)

# Raster stack dimensions
dim(lsa.variables)

# Raster resolution
res(lsa.variables)


## EXAMPLE ON ONE ROW OF A RASTER
#Retrieve values of from all rasters for a given row (here row 1)
#Here it is the 1st row of the raster
cov.Frame<- getValues(lsa.variables,1)
nrow(cov.Frame)

#Remove the pixels where there is NA or no data present
sub.frame<- cov.Frame[which(complete.cases(cov.Frame)),] 
nrow(sub.frame)
names(sub.frame)
  
#run hazelnutSuits function
hazel.lsa<- hazelnutSuits(sub.frame)

#Assess for suitability
library(matrixStats)
rowMaxs(hazel.lsa)

# A one column matrix with number of rows equal to number of columns in raser inputs
a.matrix<- matrix(NA, nrow=nrow(cov.Frame), ncol= 1)
 
#Place LSA outputs into correct row positions
a.matrix[which(complete.cases(cov.Frame)),1]<- rowMaxs(hazel.lsa)
 
#Write LSA outputs to raster object (1st row)
LSA.raster<- writeValues(LSA.raster,a.matrix[,1],1)

## FULLY SPATIAL IMPLEMENTATION
# Create a suite of rasters of same raster properties is LSA input variables
# Overall suitability classification
LSA.raster<- raster(lsa.variables[[1]])
 
# Write outputs of LSA directly to file
LSA.raster<- writeStart(LSA.raster,filename='meander_MLcat.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)


#Individual LSA input suitability rasters
mlf1<- raster(lsa.variables[[1]]); mlf2<- raster(lsa.variables[[1]]); mlf3<- raster(lsa.variables[[1]]); mlf4<- raster(lsa.variables[[1]]); mlf5<- raster(lsa.variables[[1]]); mlf6<- raster(lsa.variables[[1]]); mlf7<- raster(lsa.variables[[1]]); mlf8<- raster(lsa.variables[[1]]); mlf9<- raster(lsa.variables[[1]]); mlf10<- raster(lsa.variables[[1]])

#Also write LSA outputs directly to file.
mlf1<- writeStart(mlf1,filename='meander_Haz_mlf1_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf2<- writeStart(mlf2,filename='meander_Haz_mlf2_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf3<- writeStart(mlf3,filename='meander_Haz_mlf3_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf4<- writeStart(mlf4,filename='meander_Haz_mlf4_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf5<- writeStart(mlf5,filename='meander_Haz_mlf5_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf6<- writeStart(mlf6,filename='meander_Haz_mlf6_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf7<- writeStart(mlf7,filename='meander_Haz_mlf7_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf8<- writeStart(mlf8,filename='meander_Haz_mlf8_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf9<- writeStart(mlf9,filename='meander_Haz_mlf9_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)
mlf10<- writeStart(mlf10,filename='meander_Haz_mlf10_CAT.tif', format='GTiff',dataType = "INT1S", overwrite=TRUE)

# Run the suitability model:
 for(i in 1:dim(LSA.raster)[1]){ #Open loop:for each row of each input raster
   #get raster values
   cov.Frame<- getValues(lsa.variables,i)
   #get the complete cases
   sub.frame<- cov.Frame[which(complete.cases(cov.Frame)),]
 
   #Run hazelnut LSA function
   t1<- hazelnutSuits(sub.frame)
 
   #Save results to raster
   a.matrix<- matrix(NA, nrow=nrow(cov.Frame), ncol= 1)
   a.matrix[which(complete.cases(cov.Frame)),1]<- rowMaxs(t1)
   LSA.raster<- writeValues(LSA.raster,a.matrix[,1],i)
 
 
   #Also save the single input variable assessment outputs
   mlf.out<- matrix(NA, nrow=nrow(cov.Frame), ncol= 10)
   mlf.out[which(complete.cases(cov.Frame)),1]<- t1[,1]
   mlf.out[which(complete.cases(cov.Frame)),2]<- t1[,2]
   mlf.out[which(complete.cases(cov.Frame)),3]<- t1[,3]
   mlf.out[which(complete.cases(cov.Frame)),4]<- t1[,4]
   mlf.out[which(complete.cases(cov.Frame)),5]<- t1[,5]
   mlf.out[which(complete.cases(cov.Frame)),6]<- t1[,6]
   mlf.out[which(complete.cases(cov.Frame)),7]<- t1[,7]
   mlf.out[which(complete.cases(cov.Frame)),8]<- t1[,8]
   mlf.out[which(complete.cases(cov.Frame)),9]<- t1[,9]
   mlf.out[which(complete.cases(cov.Frame)),10]<- t1[,10]
   mlf1<- writeValues(mlf1,mlf.out[,1],i)
   mlf2<- writeValues(mlf2,mlf.out[,2],i)
   mlf3<- writeValues(mlf3,mlf.out[,3],i)
   mlf4<- writeValues(mlf4,mlf.out[,4],i)
   mlf5<- writeValues(mlf5,mlf.out[,5],i)
   mlf6<- writeValues(mlf6,mlf.out[,6],i)
   mlf7<- writeValues(mlf7,mlf.out[,7],i)
   mlf8<- writeValues(mlf8,mlf.out[,8],i)
   mlf9<- writeValues(mlf9,mlf.out[,9],i)
   mlf10<- writeValues(mlf10,mlf.out[,10],i)
   print((dim(LSA.raster)[1])-i)
   } #END OF LOOP
 
 #complete writing rasters to file
 LSA.raster<- writeStop(LSA.raster); mlf1<- writeStop(mlf1); mlf2<- writeStop(mlf2); mlf3<- writeStop(mlf3); mlf4<- writeStop(mlf4); mlf5<- writeStop(mlf5); mlf6<- writeStop(mlf6); mlf7<- writeStop(mlf7); mlf8<- writeStop(mlf8); mlf9<- writeStop(mlf9); mlf10<- writeStop(mlf10)

## PLOTTING
 library(rasterVis)
 
 LSA.raster <- as.factor(LSA.raster)
 rat <- levels(LSA.raster)[[1]]
 rat[["suitability"]] <- c("Well Suited","Suited", "Moderately Suited","Unsuited")
 levels(LSA.raster) <- rat
 
 #plot
 area_colors <- c("#FFFF00", "#1D0BE0", "#1CEB15", "#C91601")
 levelplot(LSA.raster, col.regions=area_colors, xlab="", ylab="")


 
 ## end
 
 