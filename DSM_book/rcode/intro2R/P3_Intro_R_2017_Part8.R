## R literacy: Part 8


##########################################################################################################################
## Logical thinking and algorithm development
## Principal toposequence algorithm


## The algorithm for principal toposequence can be written as:
  ## 1. Determine the highest point in an area.
  ## 2. Determine its 3 x 3 neighbor, and determine whether there are lower points?
  ## 3. If yes, set the lowest point as the next point in the toposequence, and then repeat step 2. If no, the toposequence has ended.



# function to find the lowest 3 x 3 neighbor
find_steepest<-function(dem,row_z,col_z){
  z1=dem[row_z,col_z] #elevation 
  
  # return the elevation of the neighboring values
  dir=c(-1,0,1) #neighborhood index
  nr=nrow(dem)
  nc=ncol(dem)
  pz=matrix(data=NA,nrow=3,ncol=3) #placeholder for the values
  for (i in 1:3){
    for (j in 1:3){
      if(i!=0 & j !=0) {
        ro<-row_z+dir[i]
        co<-col_z+dir[j]
        if(ro>0 & co>0 & ro<nr & co<nc) {
          pz[i,j]=dem[ro,co]}      
      }}}
  
  pz<-pz-z1# difference of neighbors from centre value
  #find lowest value
  min_pz<-which(pz==min(pz,na.rm=TRUE),arr.ind=TRUE)
  row_min<-row_z+dir[min_pz[1]]  
  col_min<-col_z+dir[min_pz[2]]
  retval<-c(row_min,col_min,min(pz,na.rm=TRUE))
  return(retval) #return the minimum
}

##RUNNING THE FUNCTION
##get data
library(ithir)
data(topo_dem)
str(topo_dem)

## Place to put transect infor
transect<-matrix(data=NA,nrow=20,ncol=3)

## Find maximum elevation (and position) within matrix
max_elev<-which(topo_dem==max(topo_dem),arr.ind=TRUE)
row_z=max_elev[1]# row of max_elev
col_z=max_elev[2]# col of max_elev
z1=topo_dem[row_z,col_z]# max elevation

#Put values into the first entry of the transect object
t<-1
transect[t,1]=row_z
transect[t,2]=col_z
transect[t,3]=z1
lowest=FALSE


# iterate down the hill until lowest point
while (lowest==FALSE) {
  result<-find_steepest(dem = topo_dem,row_z,col_z) # While condition is false find steepest neighbor
  t<-t+1
  row_z=result[1]
  col_z=result[2]
  z1=topo_dem[row_z,col_z]
  transect[t,1]=row_z
  transect[t,2]=col_z
  transect[t,3]=z1
  if(result[3]>=0) {lowest==TRUE; break}# Break if found lowest point
}

## Plot the Transect
dist=sqrt((transect[1,1]-transect[,1])^2+(transect[1,2]-transect[,2])^2)
plot(dist,transect[,3],type='l',xlab='Distance (m)', ylab='Elevation (m)')

## Algorithm for random toposequence

## 1. Select a random point from a DEM.
## 2. Travel uphill:
##  (a) Determine its 3 x 3 neighbor, and determine whether there are higher points?
##  (b) If yes, select randomly a higher point, add to the uphill sequence, and repeat step 2a. If this point is the highest, the uphill sequence ended.
## 3. Travel downhill:
##  (a) Determine its 3 x 3 neighbor, and determine whether there are lower points?
##  (b) If yes, select randomly a lower point, add to the downhill sequence, and repeat step 3a. If this point is the lowest or reached a stream, the downhill sequence ended.


#Specification of two functions


# function to simulate water moving down the slope
# input:  dem and its row & column
#         random: TRUE use random path, FALSE for steepest path
# return: row,col,z-z1 of lower neighbour
travel_down<-function(dem,row_z,col_z,random)
  
{
  z1=dem[row_z,col_z]
  # find its eight neighbour
  dir=c(-1,0,1)
  nr=nrow(dem)
  nc=ncol(dem)
  pz=matrix(data=NA,nrow=3,ncol=3)
  for (i in 1:3){
    for (j in 1:3){
        ro<-row_z+dir[i]
        co<-col_z+dir[j]
        if(ro>0 & co>0 & ro<nr & co<nc) {
          pz[i,j]=dem[ro,co]}      
      }}
  pz[2,2]=NA
  pz<-pz-z1# difference with centre value
  
  min_pz<-which(pz<0,arr.ind=TRUE)
  nlow<-nrow(min_pz)
  if(nlow==0) {
    min_pz<-which(pz==min(pz,na.rm=TRUE),arr.ind=TRUE)}
  else {  
    if(random){
      #find random lower value
        ir<-sample.int(nlow,size=1)
        min_pz<-min_pz[ir,]}
      else{
      #find lowest value
        min_pz<-which(pz==min(pz,na.rm=TRUE),arr.ind=TRUE)}
  }  
  row_min<-row_z+dir[min_pz[1]]  
  col_min<-col_z+dir[min_pz[2]]
  z_min<-dem[row_min,col_min]
  retval<-c(row_min,col_min,min(pz,na.rm=TRUE))
  return(retval)
}



# function to trace water coming from up hill
# input:  dem and its row & column
#         random: TRUE use random path, FALSE for steepest path
# return: row,col,z-zi  of higher neighbour
travel_up<-function(dem,row_z,col_z,random)
  
{
  z1=dem[row_z,col_z]
  # find its eight neighbour
  dir=c(-1,0,1)
  nr=nrow(dem)
  nc=ncol(dem)
  pz=matrix(data=NA,nrow=3,ncol=3)
  for (i in 1:3){
    for (j in 1:3){
      ro<-row_z+dir[i]
      co<-col_z+dir[j]
      if(ro>0 & co>0 & ro<nr & co<nc) {
        pz[i,j]=dem[ro,co]}      
    }}
  pz[2,2]=NA
  pz<-pz-z1# difference with centre value
  
  max_pz<-which(pz>0,arr.ind=TRUE)# find higher pixel
  nhi<-nrow(max_pz)
  if(nhi==0) {
    max_pz<-which(pz==max(pz,na.rm=TRUE),arr.ind=TRUE)}
  else {  
    if(random){
      #find random higher value
      ir<-sample.int(nhi,size=1)
      max_pz<-max_pz[ir,]}
    else{
      #find highest value
      max_pz<-which(pz==max(pz,na.rm=TRUE),arr.ind=TRUE)}
  }  
  row_max<-row_z+dir[max_pz[1]]  
  col_max<-col_z+dir[max_pz[2]]
  retval<-c(row_max,col_max,max(pz,na.rm=TRUE))
  return(retval)
}



###IMPLEMENTATION

## Select a random seed point

nr<-nrow(topo_dem)# no. rows in a DEM
nc<-ncol(topo_dem)# no. cols in a DEM

# start with a random pixel as seed point
row_z1<-sample.int(nr,1)
col_z1<-sample.int(nc,1)


# Travel uphill
# seed point as a starting point 
t<-1
transect_up<-matrix(data=NA,nrow=100,ncol=3)
row_z<-row_z1
col_z<-col_z1
z1=topo_dem[row_z,col_z]
transect_up[t,1]=row_z
transect_up[t,2]=col_z
transect_up[t,3]=z1

highest=FALSE
# iterate up the hill until highest point
while (highest==FALSE) {
  result<-travel_up(dem = topo_dem,row_z,col_z,random=TRUE)
  if(result[3]<=0) {highest==TRUE; break}# if found lowest point  
  t<-t+1
  row_z=result[1]
  col_z=result[2]
  z1=topo_dem[row_z,col_z]
  transect_up[t,1]=row_z
  transect_up[t,2]=col_z
  transect_up[t,3]=z1
}
transect_up<-na.omit(transect_up)



# travel downhill
# create a data matrix to store results
transect_down<-matrix(data=NA,nrow=100,ncol=3)
# starting point 
row_z<-row_z1
col_z<-col_z1
z1=topo_dem[row_z,col_z]# a random pixel
t<-1
transect_down[t,1]=row_z
transect_down[t,2]=col_z
transect_down[t,3]=z1
lowest=FALSE

# iterate down the hill until lowest point
while (lowest==FALSE) {
  result<-travel_down(dem = topo_dem,row_z,col_z,random=TRUE)
  if(result[3]>=0) {lowest==TRUE; break}# if found lowest point  
  t<-t+1
  row_z=result[1]
  col_z=result[2]
  z1=topo_dem[row_z,col_z]
  transect_down[t,1]=row_z
  transect_down[t,2]=col_z
  transect_down[t,3]=z1
}
transect_down<-na.omit(transect_down)

## Stitch both transect segments together
transect<- rbind(transect_up[order(transect_up[,3],
          decreasing = T),], transect_down[-1,])

# calculate distance from hilltop
dist=sqrt((transect[1,1]-transect[,1])^2+(transect[1,2]-transect[,2])^2)

## Make a plot
 plot(dist,transect[,3],type='l',col='red',xlim=c(0,100),
      ylim=c(50,120),xlab='Distance (m)',
      ylab='Elevation (m)')

## Plot the seed point
 points(dist[nrow(transect_up)],transect[nrow(transect_up),3])
 
 
 ##END

