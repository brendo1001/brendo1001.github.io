---
layout: page
title: Taking existing samples into consideration when planning an additional sampling campaign
description: "My own original content"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-04-27
---

You have an existing collection of sample data from a given spatial domain. You want to collect some new samples from this spatial domain, but want to do so in consideration of your existing samples rather than just treating it as a clean slate. Read on to find out about a few approaches on how you might do this. 


### The final word first

There was a hunch that the different approaches to selecting additional sample sites would result in different outcomes. The process of putting together this blog revealed to me that the adapted HELS algorithm explicitly and preferentially allocates additional samples to where the existing sample data coverage is most scarce. On the other hand the `clhs` approach is more subtle. From my take of the [script and notes](https://github.com/pierreroudier/clhs) about the `include` parameter of the `clhs` function is that if we have *n*1 legacy data, and we want *n*2 more new locations, the `clhs` algorithm will create *n*1+*n*2 marginal strata per covariate, and then optimization proceeds. [Kullback-Leibler divergence](https://projecteuclid.org/euclid.aoms/1177729694) mean values across each of the ancillary data revealed that the `clhs` approach resulted in sample data marginal distributions more closely resembling those of the full ancillary data, compared to the adapted HELS approach. I guess this would be expected of course. However, if the motive of a follow up sampling campaign is to preferentially fill gaps, then probably a clhs approach with existing data inclusion may not be exactly what you are after. Rather something akin to the adapted HELS algorithm is more suitable. But if you are simply interested in optimizing the marginal distributions of the sample data then `clhs` would be your choice. Of course some further tweaks can be made to the adapted HELS algorithm, so that the degree of preferential allocation could be relaxed somewhat. But this is something to be looked at in another time.

If you have found this blog at all useful and would like to cite material from it for a publication or presentation, please cite the [PeerJ paper](https://peerj.com/articles/6451/) as this is where the bulk of this workflow is derived from.


### The longer version

Recently some work was published in [PeerJ](https://peerj.com/articles/6451/) where one part of the study was describing an approach for adding new sample sites within a sampling domain where there were already some existing sites. This situation is fairly regular for example in soil survey. An initial survey of an area would be subjected to some sampling effort, then at some later date there may be some requirement to take additional samples from this site to improve the existing mapping, or simply because there are new study objectives at hand. When adding new samples, it is really useful to be able to take into account any existing samples, because there is an already accumulated knowledge from the information gained at the existing sites that it seems a wasteful job to go back over old ground. Rather, it makes more sense to acknowledge what we already have and prioritize accordingly to areas where information gathering is most needed.

In the PeerJ paper [Some methods to improve the utility of conditioned Latin hypercube sampling](https://peerj.com/articles/6451/) the described approach for achieving what was just described essentially ranked the areas within a sampling domain in terms of information deficit. Given an available sampling budget and working down the ranked list, samples were allocated accordingly. Further below the, the workflow for doing this is described in detail with text and `R` code. At about the same time as publishing this research, some updates were made to the [clhs](https://cran.r-project.org/web/packages/clhs/index.html) that allowed the prospect of fixing sampling sites (an existing collection of sample sites) and adding new samples sites via the [conditioned Latin hypercube sampling algorithm](https://www.sciencedirect.com/science/article/pii/S009830040500292X). This is achieved using the newly added `include` parameter to the `clhs` function. If you have not ever heard of conditioned Latin Hypercube sampling (clhs), then it might pay to check out any of the links provided so far. What follows is a brief description of clhs, so if you are familiar with what it does and what it achieves you can safely skip the next paragraph.

cLHS has its origins in [Latin hypercube sampling (LHS)](https://www.jstor.org/stable/1268522?origin=crossref&seq=1#page_scan_tab_contents). LHS is an efficient way to reproduce an empirical distribution function, where the idea is to divide the empirical distribution function of a variable, *X*, into *n* equi-probable, non-overlapping strata, and then draw one random value from each stratum. In a multi-dimensional setting, for *k* variables, *X*1, *X*2,...,*X**k*, the *n* random values drawn for variable *X*1 are combined randomly (or in some order to maintain its correlation) with the *n* random values drawn for variable *X*2, and so on until *n* k-tuples are formed, that is, the Latin hypercube sample. Its utility for soil sampling was noted by [Minasny & McBratney (2006)](https://www.sciencedirect.com/science/article/pii/S009830040500292X), but they recognized that some generalization of LHS sampling was required so that selected samples actually existed in the real world. Subsequently, they proposed a conditioning of the LHS, which is achieved by drawing an initial Latin hypercube sample from the ancillary information, then using simulated annealing to permute the sample in such a way that an objective function is minimized. The objective function of Minasny & McBratney (2006) comprised three criteria: 

1. Matching the sample with the empirical distribution functions of the continuous ancillary variables.
2. Matching the sample with the empirical distribution functions of the categorical ancillary variables. 
3.Matching the sample with the correlation matrix of the continuous ancillary variables.

What i wanted to understand was whether the new improvements to the `clhs` function in `R` worked in the same way or not to what was described in the [PeerJ](https://peerj.com/articles/6451.pdf) paper. The following workflow first implements each method using the same data and adding a further 100 samples within a defined sampling domain. The sample configuration derived from each method are then compared for ability preferentially fill gaps in the multi-variate data space.

Data and `R` script that contributed to the analysis in the blog can be sourced to this [github page](https://github.com/brendo1001/clhs_addition).

### Common data sets

The example draws on the data used in the [PeerJ](https://peerj.com/articles/6451.pdf) paper. These data are comprised of 332 sample site locations. There are also 7 environmental data layers at 25m grid cell resolution corresponding to various themes associated with topography, gamma radiometric and digital soil information. Note that these data sets are organised into `data.frames`.

```r
# Raster Data
str(tempD)

## 'data.frame':    335624 obs. of  10 variables:
##  $ x                             : num  335810 337235 335810 335835 335860 ...
##  $ y                             : num  6384116 6384116 6384091 6384091 6384091 ...
##  $ cellNos                       : int  53 110 728 729 730 785 786 1402 1403 1404 ...
##  $ raw_2011_ascii                : num  25.7 26.6 25.7 26 26.2 ...
##  $ thppm                         : num  11.6 11.6 11.5 11.5 11.4 ...
##  $ SAGA_wetness_index            : num  12.4 14 13 13.4 13.9 ...
##  $ MRRTF                         : num  0.969491 0.000352 0.979655 1.542369 1.047621 ...
##  $ Filled_DEM                    : num  65.7 58.3 62.5 61.7 60.7 ...
##  $ drainage_2011                 : num  4.98 2.56 4 4.7 3.96 ...
##  $ Altitude_Above_Channel_Network: num  7.03 2.53 3.84 3.04 2.05 ...

# Sample site data
str(dat)

## 'data.frame':    332 obs. of  13 variables:
##  $ id                            : Factor w/ 341 levels "a1","a10","a11",..: 1 10 23 24 25 2 3 4 5 6 ...
##  $ X                             : num  337860 340885 341835 339860 340985 ...
##  $ Y                             : num  6372416 6380691 6365966 6369066 6368241 ...
##  $ Year                          : int  2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 ...
##  $ Operator                      : Factor w/ 2 levels "Malone","Odgers": 1 1 1 1 1 1 1 1 1 1 ...
##  $ cellNos                       : num  316035 92731 490344 406565 428885 ...
##  $ raw_2011_ascii                : num  26.5 27.8 26.6 26 25.7 ...
##  $ thppm                         : num  7.34 11.7 4.96 6.98 9.29 ...
##  $ SAGA_wetness_index            : num  15.4 11.8 11.7 14.5 10.8 ...
##  $ MRRTF                         : num  0.0509 0.0293 1.216 0.1529 0.1511 ...
##  $ Filled_DEM                    : num  120 98 121 117 126 ...
##  $ drainage_2011                 : num  4.87 3.87 4.65 4.48 5 ...
##  $ Altitude_Above_Channel_Network: num  1.93 55.84 23.39 11.81 28.83 ...
```



The map below shows the spatial configuration of the sample site data.

{% include htmlwidgets/clhs1.html %}

Although unlikely to occur, the last step to happen here is to remove from the raster data the pixels that correspond to sample site locations as we do not want to run the risk of having these sites selected as additional samples.

```r
#remove the grid points where there is point data
tempD<- tempD[-which(tempD$cellNos %in% dat$cellNos),]
```


### Using the `clhs` function with the `include` parameter

The first step here is to join the point data with the raster data into
a single `data.frame`

```r
## combine grid data with the observed data
dat.sub<- dat[,c(2,3,6:13)]
names(dat.sub)[1:2]<- c("x", "y")
tempD.new<- rbind(dat.sub, tempD)
tempD.new$type<- NA
tempD.new$type[1:nrow(dat.sub)]<- "orig"
tempD.new$type[(nrow(dat.sub)+1):nrow(tempD.new)]<- "possibles"
```

Now we can run the `clhs` function. We will add a further 100 sample sites. For the `include` parameter we just need to specify the row indices that are the existing sample sites that are also returned without question once the algorithm completes running. Look to the `clhs` help file for information about other function parameters.

```r
## clhs sampling with fixed obs and add an extra 100 sites
library(clhs)
nosP<- 100 # number of additional sites

# run clhs function
res <- clhs(x = tempD.new[,c(4:10)], 
            size = nrow(dat.sub) + nosP, 
            iter = 10000, 
            progress = FALSE, 
            simple = TRUE, 
            include = c(1:nrow(dat.sub)))
```

Now we extract from the `tempD` object the rows that were selected by the clhs algorithm. We will come back to this data later once we have run through the other procedure for selecting sample sites to make some comparisons.

### Using the adapted HELS algorithm

The adapted HELS (hypercube evaluation of legacy sample) algorithm is strongly influenced by the HELS and HISQ algorithms that were introduced by [Carre et al. 2007](https://www.sciencedirect.com/science/article/pii/S0016706107000213?via%3Dihub). Essentially the goal of adapted HELS is to identify the environmental coverage of existing sample sites, and simultaneously identifying where there are gaps in the environmental data that are not covered by these same existing sample sites. Once this is achieved, new sample sites are added - where the user selects how many sites they can afford to get - and these are allocated preferentially to areas where existing sample coverage is most sparse. In words, the algorithm looks something like this:

**0a.** Select a sample size of size *s*.

**0b.** Extract the ancillary data values for existing observations *o*.

**1a.** Construct a quantile matrix of the ancillary data. If there are *k* ancillary variables, the quantile matrix will be of (*s* + 1) *k* dimensions. The rows of the matrix are the quantiles of each ancillary variable.

**1b.** Calculate the data density of the ancillary data. For each element of the quantile matrix, tally the number of pixels within the bounds of the specified quantile for that matrix element. This number is divided by *r*, where *r* is the number of pixels of an ancillary variable.

**1c.** Calculate the data density of ancillary information from the existing legacy samples. This is the same as 1b except the number of existing observations are tallied within each quantile (quantile matrix from 1a) and the density is calculated by dividing the tallied number by *o* instead of *r*.

**2.** Evaluate the ratio of densities. This is calculated as the sample point data density divided by the ancillary data density.

**3.** Rank the density ratios from smallest to largest. Across all elements of the (*s* + 1) *k* matrix of the ratios from step 2, rank them from smallest to largest. The smallest ratios indicate those quantiles that are under-sampled, and should be prioritized for selecting additional sample locations. In this ranking, it is important to save the element row and column indexes.

**4a.** Begin selection of additional sample locations. Start by initiating a sample of size *s*

**4b.** While *s* > 0 and working down the ranked list of ratios:

**5.** Estimate how many samples *m* are required to make grid density = data density. This is calculated as *o* the ancillary data density in the same row and column position as the density ratio.

**6.** Using the same row and column position of the quantile matrix from 1a, select from the ancillary data all possible locations that meet the criteria of the quantile at that position in the matrix. Select at random from this list of possible locations, *m* sampling locations.

**7.** Set *s* = *s* − *m*, then go back to 4b.

In terms of implementing the adapted HELS algorithm, we are presently up to step 1a. This is the calculation of the quantile matrix of the ancillary data.

```r
# quantile matrix (of the covariate data)
# number of quantiles = nosP
# note there are 7 covariate layers. First covariate layer in column 4
q.mat<- matrix(NA, nrow=(nosP+1), ncol= 7)
j=1
for (i in 4:ncol(tempD)){ #columnwise calculation of quantiles
  ran1<- max(tempD[,i]) - min(tempD[,i])
  step1<- ran1/nosP 
  q.mat[,j]<- seq(min(tempD[,i]), to = max(tempD[,i]), by =step1)
  j<- j+1}
```

Now for step *1b* we calculate the data density of the ancillary data. Note that currently the way this is scripted, this step does take a while to complete.

```r
#count of pixels within each quantile for each covariate
#############################################
cov.mat<- matrix(0, nrow=nosP, ncol=7)

for (i in 1:nrow(tempD)){ # the number of pixels
  cntj<- 1 
  for (j in 4:ncol(tempD)){ #for each column
    dd<- tempD[i,j]  
    for (k in 1:nosP){  #for each quantile
      kl<- q.mat[k, cntj] 
      ku<- q.mat[k+1, cntj] 
      if (dd >= kl & dd <= ku){cov.mat[k, cntj]<- cov.mat[k, cntj] + 1} 
        }
        cntj<- cntj+1
      }
    }
```

Being a little lazy so that we do not have to deal with zeros, we can just add a very small insignificant number so that the density calculation runs without issue.

```r
cov.mat[which(cov.mat==0)]<- 0.000001 
# covariate data density
covDens<- cov.mat/nrow(tempD) 
```

Now for *1c*, we just do the same as for *1b*, except we operate on the existing sample data.

```r
# First get the data shape to be like the ancillary data
dat<- dat[,c(2,3,6:13)]
names(dat)[1:2]<- c("x", "y")

h.mat<- matrix(0, nrow=nosP, ncol=7)

for (i in 1:nrow(dat)){ # the number of observations
  cntj<- 1 
  for (j in 4:ncol(dat)){ #for each column
    dd<- dat[i,j]  
    for (k in 1:nosP){  #for each quantile
      kl<- q.mat[k, cntj] 
      ku<- q.mat[k+1, cntj] 
      if (dd >= kl & dd <= ku){h.mat[k, cntj]<- h.mat[k, cntj] + 1}
        }
        cntj<- cntj+1
      }
    }

#density
h.mat[which(h.mat==0)]<- 0.000001  
datDens<-h.mat/nrow(dat) 
```

Step 2 is the calculation of the ratio of data densities.

```r
rat<- datDens/covDens 
```

Step 3 is the ranking of the ratios followed by the identification of the respective row and column positions.

```r
or<- order(rat) # rank the index where the biggest discrepancy is at the top

## indexes of quantiles that are not adequately sampled ie where rat is less than 1
l1<- which(rat < 1, arr.ind = T)
l1<- cbind(l1,which(rat < 1) )
length(rat) # total number of quantiles

## [1] 700

nrow(l1) # number of quanitles where there is a discrepancy

## [1] 445
```

The length of the `l1` object just tells us the number of quantiles where the sample data density is smaller than the ancillary data density.

Now we move onto steps 4a to 7, which deals with the sample allocation.

```r
# start from the highest discrepancy then work our way down
upSamp<- nosP
rpos<- 1 # rank
base<- 3 # constant so that covariate columns are easily to select 


while (upSamp != 0){  # while the number of samples to allocate is greater than 0
      
  # quantile position where the discrepancy is
  indy<- which(l1[,3]==or[rpos]) 
  rp<- l1[indy, 1]
  rc<- l1[indy, 2]
      
  # step 5
  ex<- floor(nrow(dat) * (datDens[rp,rc])) #existing count of samples within the selected quantile
  eq<- ceiling(nrow(dat) * (covDens[rp,rc])) # number of samples needed 
  sn<- eq-ex #number of samples needed
  if (upSamp < sn) {sn <- upSamp} # just so we dont over allocate
      
      
  #step 6
  #covariate selection
  covL<- q.mat[rp, rc]
  covU<- q.mat[rp+1, rc]
  subDat<- tempD[tempD[,(base+rc)] >= covL & tempD[,(base+rc)] <= covU,] # subset 
      
  training <- sample( nrow(subDat), sn) #random number
  subDat2<- subDat[training,]
      
  #remove selected samples from tempD so that repeated sampling does not occur 
  tempD<- tempD[!(tempD$cellNos %in% subDat2$cellNos), ]
      
  # Append new data to sampling dataframe
  dat<- rbind(dat,subDat2)
      
  #adjust the while params
  rpos<- rpos + 1 # move to next largest discrepancy
  upSamp<- upSamp - sn # update the required sample number
      }
```

### Time for comparisons

So we have created two new data sets: `dat.sel` and `dat`. Both `data.frame` have 432 rows, indicating that an additional 100 sites have been selected from the sampling domain and added to the existing sites that have already been collected from there. `dat.sel` is the output from running the `clhs` function and `dat` is the output from running the adapted HELS algorithm.

A comparison of the each of the sampling configuration here comes about by assessing the allocation of sites with respect to a COOBS (count of observations) map that has been created for this spatial domain. This map and how it was produced was also described in the [PeerJ paper](https://peerj.com/articles/6451/). Essentially it describes the spatial variation of sample data coverage of the environmental data space. High numbers mean relatively well sampled when compared to low numbers. The map below shows the COOBS map for out target area in the lower Hunter Valley.

{% include htmlwidgets/coobs.html %}

Just by intersecting the point data with the COOBS map will give us an idea of where our samples lie relative to environmental data space being covered or not.

Using the `dat.sel` object, lets see where the existing sites lay relative to the COOBS map.

```r
dat.sel.1<- as.data.frame(dat.sel[101:432, ])
sum(dat.sel.1$sampleNos >= 0 & dat.sel.1$sampleNos <= 5) / nrow(dat.sel.1) # very low coobs

## [1] 0.2590361

sum(dat.sel.1$sampleNos > 5 & dat.sel.1$sampleNos <= 10) / nrow(dat.sel.1) # low coobs

## [1] 0.1746988

sum(dat.sel.1$sampleNos > 10 & dat.sel.1$sampleNos <= 20) / nrow(dat.sel.1) # moderate coobs

## [1] 0.3042169

sum(dat.sel.1$sampleNos > 20 & dat.sel.1$sampleNos <= 40) / nrow(dat.sel.1) # high coobs

## [1] 0.2319277

sum(dat.sel.1$sampleNos > 40) / nrow(dat.sel.1) # quite high coobs

## [1] 0.03012048
```

Here we have just put some arbitrary breaks in the COOBS values. The printed values above correspond to proportions of the existing data that sit within one of the arbitrary breaks.

Now lets look at where the additional points selected by `clhs` sit relative to the COOBS values.

```r
dat.sel.2<- as.data.frame(dat.sel[1:100, ])
sum(dat.sel.2$sampleNos >= 0 & dat.sel.2$sampleNos <= 5) / nrow(dat.sel.2) # very low coobs

## [1] 0.41

sum(dat.sel.2$sampleNos > 5 & dat.sel.2$sampleNos <= 10) / nrow(dat.sel.2) # low coobs

## [1] 0.15

sum(dat.sel.2$sampleNos > 10 & dat.sel.2$sampleNos <= 20) / nrow(dat.sel.2) # moderate coobs

## [1] 0.16

sum(dat.sel.2$sampleNos > 20 & dat.sel.2$sampleNos <= 40) / nrow(dat.sel.2) # high coobs

## [1] 0.22

sum(dat.sel.2$sampleNos > 40) / nrow(dat.sel.2) # quite high coobs

## [1] 0.06
```

Lets see how these proportions compare with those samples selected by the adapted HELS algorithm.

```r
dat.2<- dat[dat$survey !=1, ]
sum(dat.2$sampleNos >= 0 & dat.2$sampleNos <= 5) / nrow(dat.2)

## [1] 0.66

sum(dat.2$sampleNos > 5 & dat.2$sampleNos <= 10) / nrow(dat.2)

## [1] 0.16

sum(dat.2$sampleNos > 10 & dat.2$sampleNos <= 20) / nrow(dat.2)

## [1] 0.12

sum(dat.2$sampleNos > 20 & dat.2$sampleNos <= 40) / nrow(dat.2)

## [1] 0.06

sum(dat.2$sampleNos > 40) / nrow(dat.2)

## [1] 0
```

Basically this comparison is telling us that the adapted HELS is allocating more samples to areas where the existing sample coverage is relatively low. In this case 66% of samples selected using adapted HELS were allocated to areas where COOBS is less than or equal to 5. For the clhs method 41% were allocated. 

Lets take a look at the spatial distribution of the sampling locations for both sampling configurations. Toggle around with the various layers on this interactive map. It is quickly apparent that the additional samples selected by either approach results in quite different spatial configurations.

{% include htmlwidgets/HELS_fin.html %}


