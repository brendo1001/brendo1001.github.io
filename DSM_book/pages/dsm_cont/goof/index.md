---
layout: page
title: Model goodness of fit
description: ""
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-07-26
---


### Diognostics

Essentially, whenever we train or calibrate a model, we can then
generate some predictions. The question one needs to ask is how good are
those predictions? Generally, we confront this question by comparing
observed values with their corresponding predictions. Some of the more
common goodness of fit measures are the root mean square error (RMSE),
bias, coefficient of determination or commonly the *R*<sup>2</sup>
value, and concordance. You will also find in the digital soil mapping
and general statisitcal literature various other model assessment
statisitcs. The RMSE is defined as:


![RMSE=\\sqrt\[2\]{(\\frac{\\sum\_{i=1}^{n}(obs\_{i}-pred\_{i})^{2}}{n})}](https://latex.codecogs.com/svg.latex?RMSE=\sqrt[2]{(\frac{\sum_{i=1}^{n}(obs_{i}-pred_{i})^{2}}{n})})


where *obs* is the observed soil property, *pred* is the
predicted soil property from a given model, and *n* is the number of
observations *i*.

Bias, also called the mean error of prediction and is defined as:

![bias=\\frac{\\sum\_{i=1}^{n}pred\_{i}-obs\_{i}}{n}](https://latex.codecogs.com/svg.latex?bias=\frac{\sum_{i=1}^{n}pred_{i}-obs_{i}}{n})

The *R*<sup>2</sup> is evaluated as the square of the sample correlation
coefficient (Pearson’s) between the observations and their corresponding
predictions. Pearson’s correlation coefficient `r` when applied to
observed and predicted values is defined as:

![r=\\frac{\\sum\_{i=1}^{n}(obs\_{i}-\\overline{obs})(pred\_{i}-\\overline{pred})}{\\sqrt\[2\]{\\sum\_{i=1}^{n}(obs\_{i}-\\overline{obs})^2}\\sqrt\[2\]{\\sum\_{i=1}^{n}(pred\_{i}-\\overline{pred})^2}}](https://latex.codecogs.com/svg.latex?r=\frac{\sum_{i=1}^{n}(obs_{i}-\overline{obs})(pred_{i}-\overline{pred})}{\sqrt[2]{\sum_{i=1}^{n}(obs_{i}-\overline{obs})^2}\sqrt[2]{\sum_{i=1}^{n}(pred_{i}-\overline{pred})^2}})

The *R*<sup>2</sup> measures the precision of the relationship (between
observed and predicted). Concordance, or more formally — Lin’s
concordance correlation coefficient (Lin (1989)), on the other hand is a
single statistic that both evaluates the accuracy and precision of the
relationship. It is often referred to as the goodness of fit along a 45
degreee line. Thus it is probably a more useful statistic than the
*R*<sup>2</sup> alone. Concordance *ρ*<sub>*c*</sub> is defined as:

![\\rho\_{c}=\\frac{2\\rho\\sigma\_{pred}\\sigma\_{obs}}{\\sigma\_{pred}^2+\\sigma\_{obs}^2+(\\mu\_{pred}-\\mu\_{obs})^2}](https://latex.codecogs.com/svg.latex?\rho_{c}=\frac{2\rho\sigma_{pred}\sigma_{obs}}{\sigma_{pred}^2+\sigma_{obs}^2+(\mu_{pred}-\mu_{obs})^2})

where *μ*<sub>*pred*</sub> and *μ*<sub>*obs*</sub> are the
means of the predicted and observed values respectively.
*σ*<sub>*pred*</sub><sup>2</sup> and
*σ*<sub>*obs*</sub><sup>2</sup> are the corresponding variances. *ρ*
is the correlation coefficient between the predictions and observations.

### Example usage

So lets fit a simple linear model. We will use the `soil.data` set from
the `ithir` package. First load the data in. We then want to regress CEC
content on clay (also be sure to remove as NAs).

```r
library(ithir)
library(MASS)
data(USYD_soil1)
soil.data <- USYD_soil1
mod.data <- na.omit(soil.data[, c("clay", "CEC")])
mod.1 <- lm(CEC ~ clay, data = mod.data, y = TRUE, x = TRUE)
mod.1

## 
## Call:
## lm(formula = CEC ~ clay, data = mod.data, x = TRUE, y = TRUE)
## 
## Coefficients:
## (Intercept)         clay  
##      3.7791       0.2053
```

You may recall that this is the same model that was fitted during the
[introduction to `R` chapter]({{ site.url }}/DSM_book/pages/r_literacy//part7/). 
What we now want to do is evaluate some of the model quality statistics
that were described above. Conveniently, these are available in the
`goof` function in the `ithir` package. We will use this function a lot
when doing digital soil mapping, so it might be useful to describe it.
`goof` takes four inputs. A vector of `observed` values, a vector of
`predicted` values, a logical choice of whether an output plot is
required, and a character input of what type of output is required.
There are number of possible goodness of fit statistics that can be
requested, with only some being used frequently in digital soil mapping
projects. Therefore setting the `type` parameter to `DSM` will output
only the *R*<sup>2</sup>, RMSE, MSE, bias and concordance statistics as
these are most most relevant to DSM. Additional statitistics can be
returned if `spec` is specified for the `type` parameter.

```r
goof(observed = mod.data$CEC, predicted = mod.1$fitted.values, type = "DSM")

##          R2 concordance      MSE     RMSE bias
## 1 0.4213764   0.5888521 14.11304 3.756733    0
```

You may wish to generate a plot in which case you would set the
`plot.it` logical to `TRUE`. Note that the `MASS` package also needs to
be installed and loaded if you want to use the `plot.it` parameter.

This model `mod.1` does not seem to be too bad. On average the
predictions are 3.75 cmol (+)/*kg* off the true value. The model on
average is neither over- or under-predictive, but we can see that a few
high CEC values are influencing the concordance and *R*<sup>2</sup>.
This outcome may mean that there are other factors that influence the
CEC, such as mineralogy type for example.

### References

Lin, L I. 1989. “A Concordance Correlation Coeficient to Evaluate
Reproducibility.” *Biometrics* 45: 255–68.