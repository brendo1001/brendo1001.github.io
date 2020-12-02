---
layout: post
title: Journal Paper Digests
author: Brendan Malone
create: 2018-10-11
modified: 2018-10-11
image:
    feature: CachedImage.jpg
categories: [Research, Digests]
tags: [Journal Papers, Research]
---

## Journal Paper Digests 2018 #20


* Multi-objective unstructured triangular mesh generation for use in hydrological and land surface models





<!--more-->

### Multi-objective unstructured triangular mesh generation for use in hydrological and land surface models

Authors:
Marsh, CB; Spiteri, RJ; Pomeroy, JW; Wheater, HS

Source:
*COMPUTERS & GEOSCIENCES*, 119 49-67; OCT 2018 

Abstract:
Unstructured triangular meshes are an efficient and effective landscape
representation that are suitable for use in distributed hydrological and
land surface models. Their variable spatial resolution provides similar
spatial performance to high-resolution structured grids while using only
a fraction of the number of elements. Many existing triangulation
methods either sacrifice triangle quality to introduce variable
resolution or maintain well formed uniform meshes at the expense of
variable triangle resolution. They are also generally constructed to
only fulfil topographic constraints. However, distributed hydrological
and land surface models require triangles of varying resolution to
provide landscape representations that accurately represent the spatial
heterogeneity of driving meteorology, physical parameters and process
operation in the simulation domain. As such, mesh generators need to
constrain the unstructured mesh to not only topography but to other
important surface and sub-surface features. This work presents novel
multi-objective unstructured mesh generation software that allows mesh
generation to be constrained to an arbitrary number of important
features while maintaining a variable spatial resolution. Triangle
quality is supported as well as a smooth gradation from small to large
triangles. Including these additional constraints results in a better
representation of spatial heterogeneity than from classic
topography-only constraints.
