---
layout: page
title: R Literacy
description: "Part 4"
header-img: images/pedometric2017.jpg
comments: false
modified: 2020-04-26
---

Code is [here]({{ site.url }}/DSM_book/rcode/intro2R/P3_Intro_R_2017_Part4.R)

Graphics: the basics
--------------------

### Introduction to the `plot` function

It is easy to produce publication-quality graphics in `R`. There are
many excellent `R` packages at your finger tips to do this; some of
which include `lattice` and `ggplot2` (see the help files and
documentation for these). While in the course of these exercises we will
revert to using these other plotting packages, some fundamentals of
plotting need to bedded down. Therefore in this section we will focus on
the simplest plots; those which can be produced using the `plot`
function, which is a base function that comes with `R`. This function
produces a plot as a side effect, but the type of plot produced depends
on the type of data submitted. The basic plot arguments, as given in the
help file for `plot.default` are:

```r
`plot(x, y = NULL, type = 'p',  xlim = NULL, ylim = NULL, log = NULL, main = NULL, sub = NULL, xlab = NULL, ylab = NULL, ann = par('ann'), axes = TRUE, frame.plot = axes, panel.first = NULL, panel.last = NULL, asp = NA, ...)`
```

To plot a single vector, all we need to do is supply that vector as the
only argument to the function.

```r
    z<- rnorm(10)
    plot (z)
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/Rgraphic1.png" alt="rconsole">
    <figcaption> Your first plot.</figcaption>
</figure>


In this case, `R` simply plots the data in the order they occur in the
vector. To plot one variable versus another, just specify the two
vectors for the first two arguments.

```r
    x<- -15:15
    y<- x^2
    plot(x,y)
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/Rgraphic2.png" alt="rconsole">
    <figcaption> Your Second plot.</figcaption>
</figure>

And this is all it takes to generate plots in `R`, as long as you like
the default settings. Of course, the default settings generally will not
be sufficient for publication- or presentation-quality graphics.
Fortunately, plots in `R` are very flexible. The table below shows some
of the more common arguments to the `plot` function, and some of the
common settings. For many more arguments, see the help file for `par` or
consult some online materials where <http://www.statmethods.net/graphs/>
is a useful starting point.

<table>
<colgroup>
<col style="width: 6%" />
<col style="width: 27%" />
<col style="width: 65%" />
</colgroup>
<thead>
<tr class="header">
<th>Argument</th>
<th>Common Options</th>
<th>Additional Information</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>lty</code></td>
<td><code>0</code> <code>1</code> or <code>solid</code> <code>2</code> or <code>dashed</code> <code>3</code> or <code>dashed</code> through <code>6</code></td>
<td>Line types</td>
</tr>
<tr class="even">
<td><code>pch</code></td>
<td>0 through 25</td>
<td>Plotting symbols. See below for symbols. Can also use any single character, e.g., <code>v</code>, or <code>X</code> etc.</td>
</tr>
<tr class="odd">
<td><code>type</code></td>
<td><code>p</code> for points <code>l</code> for line <code>b</code> for both <code>o</code> for over <code>n</code> for none</td>
<td><code>n</code> can be handy for setting up a plot that you later add data to</td>
</tr>
<tr class="even">
<td><code>xlab</code>, <code>ylab</code></td>
<td>Any character string, e.g. <code>soil depth</code></td>
<td>For specifying axis labels</td>
</tr>
<tr class="odd">
<td><code>xlim</code>, <code>ylim</code></td>
<td>Any two element vector, e.g. <code>c(0:100)</code>, <code>c(-10,10)</code>, <code>c(55,0)</code></td>
<td>List higher value first to reverse axis</td>
</tr>
<tr class="even">
<td><code>col</code></td>
<td><code>red</code>, <code>blue</code>, <code>1</code> through <code>657</code></td>
<td>Colour of plotting symbols and lines. Type <code>colors()</code> to get list. You can also mix your own colours. See “color specification” in the help file for <code>par</code>.</td>
</tr>
<tr class="odd">
<td><code>bg</code></td>
<td><code>red</code>, <code>blue</code>, many more</td>
<td>Colour of fill for some plotting symbols (see below)</td>
</tr>
<tr class="even">
<td><code>las</code></td>
<td><code>0</code>, <code>1</code>, <code>2</code>, <code>3</code></td>
<td>Rotation of numeric axis labels</td>
</tr>
<tr class="odd">
<td><code>main</code></td>
<td>Any character string e.g. <code>plot 1</code></td>
<td>Adds a main title at the top of the plot</td>
</tr>
<tr class="even">
<td><code>log</code></td>
<td><code>x</code>, <code>y</code>, <code>xy</code></td>
<td>For making logarithmic scaled axes</td>
</tr>
</tbody>
</table>

Use of some of the arguments in the above table is shown in the
following example.

```r
    plot(x,y, type="o", xlim=c(-20,20), ylim=c(-10,300), 
         pch=21, col="red", bg="yellow", 
         xlab="The X variable", ylab="X squared")
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/Rgraphic3.png" alt="rconsole">
    <figcaption> Your first plot using some of the `plot` arguments.</figcaption>
</figure>


The `plot` function is effectively vectorised. It accepts vectors for
the first two arguments (which specify the x and y position of your
observations), but can also accept vectors for some of the other
arguments, including `pch` or `col`. Among other things, this provides
an easy way to produce a reference plot demonstrating `R`’s plotting
symbols and lines. If you use `R` regularly, you may want to print a
copy out (or make your own).

```r
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
```

<figure>
    <img src="{{ site.url }}/images/dsm_book/Rgraphic4.png" alt="rconsole">
    <figcaption> Illustration of some of the `plot` arguments and symbols.</figcaption>
</figure>


### Exercises

1.  Produce a data frame with two columns: *x*, which ranges from
    −2*π* to 2*π* and has a small interval between values (for
    plotting), and cosine(*x*). Plot the cosine(*x*) vs. *x* as a line.
    Repeat, but try some different line types or colours.

2.  Read in the data from the `ithir` package called `USYD_dIndex`,
    which contains some observed soil drainage characteristics based on
    some defined soil colour and drainage index (first column). In the
    second column is a corresponding prediction which was made by a soil
    spatial prediction function. Plot the observed drainage index
    (`DI_observed`) vs. the predicted drainage index (`DI_predicted`).
    Ensure your plot has appropriate axis limits and labels, and a
    heading. Try a few plotting symbols and colours. Add some
    informative text somewhere. If you feel inspired, draw a line of
    concordance i.e. a 1:1 line on the plot.
