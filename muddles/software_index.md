---
layout: page
title: Software
description: "Polyorder - Gyroid - PyDiagram - NGPy - mpltex."
header-img: images/software-1.jpg
comments: false
modified: 2015-04-15
---

Scientific software development plays a very important role in my research. Along with my research, I have developed some computing software to carry out the actual task. The software are coded in various programming languages, such as C/C++, Python, Matlab, Fortran and so on. All software listed here are open source software. They are licensed by either BSD or GPL v3.

## Polyorder
-----

Polyorder is a C++ library which aims to ease the development of polymer self-consistent field theory (SCFT) programs.

### Features


* Flexibility. All components can be replaced.

* Extensibility. The OO design enables one add new features smoothly.

* Non-orthogonal unit cell calculations are supported.

* Weakly charged polymers are supported natively.

* Supporting scripts.

### Getting Started

* [Introduction to the Polyorder project]({{ site.url }}/downloads/polyorder20120628.pdf)

* [Configuration file format]({% post_url 2015-04-06-polyorder-config %})

### Useful Links

* [Polyorder source code](https://bitbucket.org/liuyxpp/polyorder)

* [Polyorder documentation](https://bitbucket.org/liuyxpp/polyorder)

## PyDiagram
-----

PyDiagram is a python package for generating phase diagrams from results output by polymer field-theoretic simulations. PyDiagram also provides functions for analysis of simulation results.

### Features

* Processor: support Polyorder and PolyFTS output files, and a general dgm file containing all simulation results.

* Plotter: provide plots of raw, invalid, phase boundary, and standard phase diagrams.

* Analyzer: the trend of the free energy, stretch-free cell size, and accuracy.

* A project configuration file provides full control of the processor, plotter, and analyzer.

### Useful Links

* [PyDiagram source code](https://github.com/liuyxpp/pydiagram)

* [PyDiagram PyPI page](http://pypi.python.org/pypi/pydiagram)

## Gyroid
-----

Gyroid is a python package that generates *symmetry adapted basis functions* based on the space group of a unit cell.

### Features

* Support 1D, 2D and 3D symmetry groups.

* Has a structure renderer.

* Output data as input data for polyorder.

* Install with pip/easy_install

* Well documented.

### Links

- [Gyroid source code](https://bitbucket.org/liuyxpp/gyroid)

- [Gyroid PyPI page](pypi.python.org/pypi/gyroid)

- [Gyroid documentation](http://packages.python.org/gyroid/)

## NGPy
-----

NGPy is a web application that enable online performing and analyzing Monte-Carlo simulation on nucleation and growth phenomena. It can be also used as a web framework to develop your own web applications.

### Features

* Multiple simulation instances.

* Analyze simulation data online.

* Retrieve result data online.

* Install with pip/easy_install

### Useful Links

- [NGPy source code](https://bitbucket.org/liuyxpp/ngpy)

- [NGPy PyPI page](pypi.python.org/pypi/ngpy)

- [NGPy documentation](http://pypi.python.org/pypi/ngpy)

## mpltex
-----

mpltex is a python package for creating publication-quality plots using matplotlib. Inspired by [Olga Botvinnik](http://olgabotvinnik.com/)'s python package [prettyplotlib](https://github.com/olgabot/prettyplotlib).

### Features

* Create plots for American Chemical Society.

* Create plots for presentation slides.

* Create plots for webpages.

* The internal matplotlib color cycle is replaced by ColorBrewer Set1 scale which looks less saturated and more pleasing to eyes.

* enable cycle line styles and a selected set of line markers including hollow type markers.

### Getting Started

- [Reading the tutorial]({% post_url 2014-09-09-mpltex %})

### Useful Links

- [mpltex source code](https://github.com/liuyxpp/mpltex)

- [mpltex PyPI page](http://pypi.python.org/pypi/mpltex)
