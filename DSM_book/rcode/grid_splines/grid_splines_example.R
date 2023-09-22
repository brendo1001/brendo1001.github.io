# Purpose        : Example of application of spline depth function on raster grids
# Maintainer     : Brendan Malone (brendan.malone@csiro.au; 
# Contributions  : 
# Status         : working
# Note           : Mass-preserving spline explained in detail in [http://dx.doi.org/10.1016/S0016-7061(99)00003-8];
# Last Modified  : 2023-09-22

library(terra)

# load spline raster function
source("/home/brendo1001/mystuff/devs/site_source/DSM_book/rcode/grid_splines/ea_ras_func.R")


# Download SLGA V2 mapping
SLGA_V2_clay <- c('/vsicurl/https://esoil.io/TERNLandscapes/Public/Products/TERN/SLGA/CLY/CLY_000_005_EV_N_P_AU_TRN_N_20210902.tif',
        '/vsicurl/https://esoil.io/TERNLandscapes/Public/Products/TERN/SLGA/CLY/CLY_005_015_EV_N_P_AU_TRN_N_20210902.tif',
        '/vsicurl/https://esoil.io/TERNLandscapes/Public/Products/TERN/SLGA/CLY/CLY_015_030_EV_N_P_AU_TRN_N_20210902.tif',
        '/vsicurl/https://esoil.io/TERNLandscapes/Public/Products/TERN/SLGA/CLY/CLY_030_060_EV_N_P_AU_TRN_N_20210902.tif',
        '/vsicurl/https://esoil.io/TERNLandscapes/Public/Products/TERN/SLGA/CLY/CLY_060_100_EV_N_P_AU_TRN_N_20210902.tif',
        '/vsicurl/https://esoil.io/TERNLandscapes/Public/Products/TERN/SLGA/CLY/CLY_100_200_EV_N_P_AU_TRN_N_20210902.tif')

# load in rasters and stack
SLGA_V2_clay.stk <- terra::rast(SLGA_V2_clay)
SLGA_V2_clay.stk

aoi <- terra::ext(149.00,149.1, -35.50, -35.40)
rc <- terra::crop(SLGA_V2_clay.stk, aoi)
plot(rc)

# use raster spline function with unusual depth interval outputs
rc.new<- ea_rasSp(obj= rc, # raster stack object
                  lam = 0.1, # lambda
                  # These are SLGA standard depths (but could be any depths though)
                  dIn = c(0,5,15,30,60,100,200), 
                  # User specified depths
                  dOut = c(0,11,25,31,50,180),   
                  vlow = 0, 
                  vhigh = 100,
                  show.progress=FALSE)

rc.new

# make a plot
plot(rc.new)

# use raster spline function with less unusual depth interval outputs
rc.new2<- ea_rasSp(obj= rc, # raster stack object
                  lam = 0.1, # lambda
                  # These are SLGA standard depths (but could be any depths though)
                  dIn = c(0,5,15,30,60,100,200), 
                  # User specified depths
                  dOut = c(0,10,30,100),   
                  vlow = 0, 
                  vhigh = 100,
                  show.progress=FALSE)

rc.new2

# make a plot
plot(rc.new2)



