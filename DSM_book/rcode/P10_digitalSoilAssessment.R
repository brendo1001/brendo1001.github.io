# ******************************************************************************
# *                                                                            
# *                           [Digital soil assessment: A simple enterprise suitability example.]                                
# *                                                                            
# *  Description:                                                              
##    
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
# *  2023-09-13             
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
#     Kidd, Darren B., M. A. Webb, C. J. Grose, R. M. Moreton, 
#     Brendan P. Malone, Alex B. McBratney, Budiman Minasny, 
#     Raphael Viscarra-Rossel, L. A. Sparrow, and R. Smith. 
#     2012. “Digital Soil Assessment: Guiding Irrigation Expansion in 
#     Tasmania, Australia.” Edited by Budiman Minasny, 
#     Brendan P. Malone, and Alex B. McBratney. Boca Raton: CRC.
#
# *  The Data is provided "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
# *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
# *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    
# *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR      
# *  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,      
# *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA OR THE USE OR OTHER   
# *  DEALINGS IN THE DATA                                                                       
# ******************************************************************************

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
  out.matrix[which(samp.matrix[,5] == 0),5]<- 1
  out.matrix[which(samp.matrix[,5] != 0 & samp.matrix[,6] >= 80),5]<- 1
  out.matrix[which(samp.matrix[,5] != 0 & samp.matrix[,6] < 80 & samp.matrix[,6] >= 60),5]<- 2
  out.matrix[which(samp.matrix[,5] != 0 & samp.matrix[,6] < 60 & samp.matrix[,6] >= 40),5]<- 3
  out.matrix[which(samp.matrix[,5] != 0 & samp.matrix[,6] < 40),5]<- 3
  
  # pH
  out.matrix[which(samp.matrix[,7] <=6.5 & samp.matrix[,7] >=5.5 ),6]<- 1
  out.matrix[which(samp.matrix[,7] >6.5 & samp.matrix[,7] <=7.1 ),6]<- 3
  out.matrix[which(samp.matrix[,7] < 5.5 | samp.matrix[,7] >7.1 ),6]<- 4
  
  #rainfall
  out.matrix[which(samp.matrix[,8] <=50),7]<- 1
  out.matrix[which(samp.matrix[,8] > 50),7]<- 4
  
  #soil depth
  out.matrix[which(samp.matrix[,9] == 0),8]<- 1
  out.matrix[which(samp.matrix[,9] != 0 & samp.matrix[,10] > 50),8]<- 1
  out.matrix[which(samp.matrix[,9] != 0 & samp.matrix[,10] <= 50 & samp.matrix[,10] > 40),8]<- 2
  out.matrix[which(samp.matrix[,9] != 0 & samp.matrix[,10] <= 40 & samp.matrix[,10] > 30),8]<- 3
  out.matrix[which(samp.matrix[,9] != 0 & samp.matrix[,10] <= 30),8]<- 4
  
  # temperature
  out.matrix[which(samp.matrix[,11] >20 & samp.matrix[,11] <=30 ),9]<- 1
  out.matrix[which(samp.matrix[,11] >30 & samp.matrix[,11] <=33 | samp.matrix[,11] <=20 & samp.matrix[,11] >18 ),9]<- 2
  out.matrix[which(samp.matrix[,11] >33 & samp.matrix[,11] <=35 ),9]<- 3
  out.matrix[which(samp.matrix[,11] >35 | samp.matrix[,11] <=18),9]<- 4
  
  # rocks
  out.matrix[which(samp.matrix[,12] == 0),10]<- 1
  out.matrix[which(samp.matrix[,12] != 0 & samp.matrix[,13] <= 2),10]<- 1
  out.matrix[which(samp.matrix[,12] != 0 & samp.matrix[,13] == 3),10]<- 2
  out.matrix[which(samp.matrix[,12] != 0 & samp.matrix[,13] == 4),10]<- 3
  out.matrix[which(samp.matrix[,12] != 0 & samp.matrix[,13] > 4),10]<- 4
  
  return(out.matrix)}


library(ithir);library(terra);library(matrixStats);library(rasterVis)
## Data for the exercise
# grids (lsa rasters from ithir package)
lsa.variables <- list.files(path = system.file("extdata/dsa/", package = "ithir"), pattern = ".tif", full.names = TRUE)

# read them into R as SpatRaster objects
lsa.variables <- terra::rast(lsa.variables)

#LSA input variables
names(lsa.variables)
class(lsa.variables)

# Raster stack dimensions
terra::nlyr(lsa.variables);terra::nrow(lsa.variables);terra::ncol(lsa.variables)

# Raster resolution
terra::res(lsa.variables)

## EXAMPLE ON ONE ROW OF A RASTER
#Retrieve values of from all rasters for a given row (here row 1)
#Here it is the 100th row of the raster
cov.Frame<- lsa.variables[100,]
nrow(cov.Frame)

#Remove the pixels where there is NA or no data present
sub.frame<- cov.Frame[which(complete.cases(cov.Frame)),] 
nrow(sub.frame)
names(sub.frame)
  
#run hazelnutSuits function
# order the data frame so columns match to assessment criteria
sub.frame<- sub.frame[,c(1,4:13,2,3)]
hazel.lsa<- hazelnutSuits(sub.frame)

#Assess for suitability
matrixStats::rowMaxs(hazel.lsa)

# A one column matrix with number of rows equal to number of columns in raser inputs
a.matrix<- matrix(NA, nrow=nrow(cov.Frame), ncol= 1)
 
#Place LSA outputs into correct row positions
a.matrix[which(complete.cases(cov.Frame)),1]<- matrixStats::rowMaxs(hazel.lsa)
 
#Write LSA outputs to raster object (1st row)
LSA.raster<- terra::writeValues(x = LSA.raster, v = a.matrix[,1],start = 1, nrows = 1)

## FULLY SPATIAL IMPLEMENTATION
# Create a suite of rasters of same raster properties is LSA input variables
loc<- "/home/brendo1001/tempfiles/"
# Overall suitability classification
LSA.raster<- rast(lsa.variables[[1]])
# Write outputs of LSA directly to file
terra::writeStart(LSA.raster,filename=paste0(loc,'meander_MLcat.tif'),datatype = "INT2S", overwrite=TRUE)

#Individual LSA input suitability rasters
mlf1<- rast(lsa.variables[[1]]); mlf2<- rast(lsa.variables[[1]]); mlf3<- rast(lsa.variables[[1]]); mlf4<- rast(lsa.variables[[1]]); mlf5<- rast(lsa.variables[[1]]); mlf6<- rast(lsa.variables[[1]]); mlf7<- rast(lsa.variables[[1]]); mlf8<- rast(lsa.variables[[1]]); mlf9<- rast(lsa.variables[[1]]); mlf10<- rast(lsa.variables[[1]])

#Also write LSA outputs directly to file.
terra::writeStart(mlf1,filename=paste0(loc,'meander_Haz_mlf1_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf2,filename=paste0(loc,'meander_Haz_mlf2_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf3,filename=paste0(loc,'meander_Haz_mlf3_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf4,filename=paste0(loc,'meander_Haz_mlf4_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf5,filename=paste0(loc,'meander_Haz_mlf5_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf6,filename=paste0(loc,'meander_Haz_mlf6_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf7,filename=paste0(loc,'meander_Haz_mlf7_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf8,filename=paste0(loc,'meander_Haz_mlf8_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf9,filename=paste0(loc,'meander_Haz_mlf9_CAT.tif'),datatype = "INT2S", overwrite=TRUE)
terra::writeStart(mlf10,filename=paste0(loc,'meander_Haz_mlf10_CAT.tif'),datatype = "INT2S", overwrite=TRUE)

# Run the suitability model:
 for(i in 1:nrow(LSA.raster)){ #Open loop:for each row of each input raster
   #get raster values
   cov.Frame<- lsa.variables[i,]
   #get the complete cases
   sub.frame<- cov.Frame[which(complete.cases(cov.Frame)),]
   
   # re-order the data frame
   sub.frame<- sub.frame[,c(1,4:13,2,3)]
   
 
   #Run hazelnut LSA function
   t1<- hazelnutSuits(sub.frame)
 
   #Save results to raster
   a.matrix<- matrix(NA, nrow=nrow(cov.Frame), ncol= 1)
   a.matrix[which(complete.cases(cov.Frame)),1]<- matrixStats::rowMaxs(t1)
   terra::writeValues(LSA.raster,a.matrix[,1],start = i,nrows=1)
 
 
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
   terra::writeValues(mlf1,mlf.out[,1],start = i,nrows=1)
   terra::writeValues(mlf2,mlf.out[,2],start = i,nrows=1)
   terra::writeValues(mlf3,mlf.out[,3],start = i,nrows=1)
   terra::writeValues(mlf4,mlf.out[,4],start = i,nrows=1)
   terra::writeValues(mlf5,mlf.out[,5],start = i,nrows=1)
   terra::writeValues(mlf6,mlf.out[,6],start = i,nrows=1)
   terra::writeValues(mlf7,mlf.out[,7],start = i,nrows=1)
   terra::writeValues(mlf8,mlf.out[,8],start = i,nrows=1)
   terra::writeValues(mlf9,mlf.out[,9],start = i,nrows=1)
   terra::writeValues(mlf10,mlf.out[,10],start = i,nrows=1)
   print((nrow(LSA.raster))-i)
   } #END OF LOOP
 
#complete writing rasters to file
LSA.raster<- writeStop(LSA.raster); mlf1<- writeStop(mlf1); mlf2<- writeStop(mlf2); mlf3<- writeStop(mlf3); mlf4<- writeStop(mlf4); mlf5<- writeStop(mlf5); mlf6<- writeStop(mlf6); mlf7<- writeStop(mlf7); mlf8<- writeStop(mlf8); mlf9<- writeStop(mlf9); mlf10<- writeStop(mlf10)

## PLOTTING
names(LSA.raster)<- "Hazelnut suitability"
LSA.raster <- as.factor(LSA.raster)
levels(LSA.raster) = data.frame(value=1:4, desc = c("Well Suited","Suited", "Moderately Suited","Unsuited"))
area_colors <- c("#FFFF00", "#1D0BE0", "#1CEB15", "#C91601")
plot(LSA.raster, col = area_colors,plg = list(loc = "bottomright"))


## END
 
 