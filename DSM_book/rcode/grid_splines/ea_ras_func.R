# Purpose        : Fits a mass-preserving (pycnophylactic) spline to layered soil map. Raster data implementation
# Maintainer     : Brendan Malone (brendan.malone@csiro.au; 
# Contributions  : 
# Status         : working
# Note           : Mass-preserving spline explained in detail in [http://dx.doi.org/10.1016/S0016-7061(99)00003-8];
# Last Modified  : 2019-12-23

# Notes
# object is a raster stack 
# When we say layered soil maps we mean the composite of the maps is a representation of the vertical and lateral variation of a specified soil variable.
# The spatial or lateral support maybe either a block or a point but the vertical support are that the layers represented average values for the specified depth interval.
# FOr example the Global Soil Map outputs specify mapping to be produced at 0-5, 5-15, 15-30, 30-60, 60-100 andd 100-200cm. The values for these depths should represent averages 
# otherwise the spline model will not be appropriate becasue it fits the spline such that mass-balance is achieved across all depths. 


# Spline fitting for horizon data (Matlab Code converted to R by Brendan Malone)
ea_rasSp<- function(obj= NULL, 
                    lam = 0.1, 
                    dIn = c(0,5,15,30,60,100,200),
                    dOut = c(0,30,60),
                    vlow = 0, 
                    vhigh = 100,
                    show.progress=TRUE){
  
  # Manipulate data from raster to lists 
  # organise rasters into a table format
  tempD <- data.frame(cellNos = seq(1:ncell(obj)))
  vals <- as.data.frame(terra::values(obj))
  tempD<- cbind(tempD, vals)
  cellNos <- c(tempD$cellNos)
  gXY <- data.frame(terra::xyFromCell(obj, cellNos))
  tempD<- cbind(gXY, tempD)
  #str(tempD)
  
  # table for outputs
  tempE<- tempD[,1:3]
  # addtional columns
  ac<- length(dOut)-1
  for (asth in 1:ac) {
    a1<-paste0(dOut[asth],"-",dOut[asth+1], "cm")
    tempE[a1] <- NA}
  
  
  if (show.progress) pb <- txtProgressBar(min=0, max=nrow(tempD), style=3)
  # go through each pixel
  for (i in 1:nrow(tempD)){
    
    # if missing value move to next entry
    if(is.na(tempD[i,4])){next}
    
    # Organise data
    i1<- rep(tempD[i,3], length.out = length(dIn) -1) # id [cell number]
    i2<- dIn[1:length(dIn)-1] # upper depth
    i3<- dIn[2:length(dIn)] # lower depth
    i4<- c(tempD[i,4:ncol(tempD)])
    subs<- as.data.frame(cbind(i1,i2,i3,i4))
    rownames(subs) <- c()
    names(subs)<- c("ID", "Upper", "Lower", "Val")
    
    subs<-as.matrix(subs)
    
    # manipulate the profile data to the required form
    ir<- c(1:nrow(subs))
    ir<-as.matrix(t(ir))
    u<- as.numeric(subs[ir,2])
    u<-as.matrix(t(u))   # upper 
    v<- as.numeric(subs[ir,3])
    v<-as.matrix(t(v))   # lower
    y<- as.numeric(subs[ir,4])
    y<-as.matrix(t(y))   # concentration 
    n<- length(y);       # number of observations in the profile
    dIn<- t(dIn)
    
    ###############################################################################################################################################################
    ## ESTIMATION OF SPLINE PARAMETERS
    np1 <- n+1  # number of interval boundaries
    nm1 <- n-1
    delta <- v-u  # depths of each layer
    del <- c(u[2:n],u[n])-v   # del is (u1-v0,u2-v1, ...)
      
    ## create the (n-1)x(n-1) matrix r; first create r with 1's on the diagonal and upper diagonal, and 0's elsewhere
    r <- matrix(0,ncol=nm1,nrow=nm1)
    for(dig in 1:nm1){
      r[dig,dig]<-1}
    for(udig in 1:nm1-1){
      r[udig,udig+1]<-1}
      
    ## then create a diagonal matrix d2 of differences to premultiply the current r
    d2 <- matrix(0, ncol=nm1, nrow=nm1)
    diag(d2) <- delta[2:n]  # delta = depth of each layer
      
    ## then premultiply and add the transpose; this gives half of r
    r <- d2 %*% r
    r <- r + t(r)
      
    ## then create a new diagonal matrix for differences to add to the diagonal
    d1 <- matrix(0, ncol=nm1, nrow=nm1)
    diag(d1) <- delta[1:nm1]  # delta = depth of each layer
      
    d3 <- matrix(0, ncol=nm1, nrow=nm1)
    diag(d3) <- del[1:nm1]  # del =  differences
      
    r <- r+2*d1 + 6*d3
      
    ## create the (n-1)xn matrix q
    q <- matrix(0,ncol=n,nrow=n)
    for (dig in 1:n){
      q[dig,dig]<- -1 }
    for (udig in 1:n-1){
      q[udig,udig+1]<-1}
    
    q <- q[1:nm1,1:n]
    dim.mat <- matrix(q[],ncol=length(1:n),nrow=length(1:nm1))
      
    ## inverse of r
    rinv <- try(solve(r), TRUE)
      
    ## Note: in same cases this will fail due to singular matrix problems, hence you need to check if the object is meaningfull:
    if(is.matrix(rinv)){
      ## identity matrix i
      ind <- diag(n)
        
      ## create the matrix coefficent z
      pr.mat <- matrix(0,ncol=length(1:nm1),nrow=length(1:n))
      pr.mat[] <- 6*n*lam
      fdub <- pr.mat*t(dim.mat)%*%rinv
      z <- fdub%*%dim.mat+ind
        
      ## solve for the fitted layer means
      sbar <- solve(z,t(y))
      
      ## calculate the fitted value at the knots
      b <- 6*rinv%*%dim.mat%*% sbar
      b0 <- rbind(0,b) # add a row to top = 0
      b1 <- rbind(b,0) # add a row to bottom = 0
      gamma <- (b1-b0) / t(2*delta)
      alfa <- sbar-b0 * t(delta) / 2-gamma * t(delta)^2/3
        
      ## END ESTIMATION OF SPLINE PARAMETERS
      ###############################################################################################################################################################
        
        
      ## fit the spline 
      mxd<- dIn[length(dIn)]
      xfit<- as.matrix(t(c(1:mxd))) ## spline will be interpolated onto these depths (1cm res)
      nj<- max(v)
      if (nj > mxd){
        nj<- mxd}
      yfit<- xfit
      for (k in 1:nj){
        xd<-xfit[k]
        if (xd< u[1]){
          p<- alfa[1]} else {
            for (its in 1:n) {
              if(its < n){
                tf2=as.numeric(xd>v[its] & xd<u[its+1])} else {
                  tf2<-0}
              if (xd>=u[its] & xd<=v[its]){
                p=alfa[its]+b0[its]*(xd-u[its])+gamma[its]*(xd-u[its])^2} else if (tf2){
                  phi=alfa[its+1]-b1[its]*(u[its+1]-v[its])
                  p=phi+b1[its]*(xd-v[its])}
            }
          }
        yfit[k]=p }
      if (nj < mxd){yfit[,(nj+1):mxd]=NA}
      
      yfit[which(yfit > vhigh)] <- vhigh
      yfit[which(yfit < vlow)]  <-vlow
      
      ## Averages of the spline at specified depths
      nd<- length(dOut)-1  # number of depth intervals
      dl<-dOut+1     #  increase d by 1
      colD<- 4
      for (cj in 1:nd) { 
        xd1<- dl[cj]
        xd2<- dl[cj+1]-1
        if (nj>=xd1 & nj<=xd2){
          xd2<- nj-1
          tempE[i,colD]<- mean(yfit[,xd1:xd2])} else {
            tempE[i,colD]<- mean(yfit[,xd1:xd2])}# average of the spline at the specified depth intervals
        colD<- colD + 1} 
    }
    if (show.progress) { setTxtProgressBar(pb, i)  }
  }
  if (show.progress) {close(pb)}
  
  # rasterise the data and stack
  sz<- list()
  cnts<- 1
  for (mks in 4:ncol(tempE)){
    sz[[cnts]]<- c(terra::rast(tempE[,c(1,2,mks)], type = "xyz"))
    cnts<- cnts + 1}
   sz<- rast(sz)
  
  # save outputs
  return(sz)}

# end of script;