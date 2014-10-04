
Overview
=============
This package is provided to give researchers quick and convenient access to OpenStreetMap data in Julia. It provides means for extracting and classifying map data, basic route planning, and convenient data visualization.

I found comparable tools for Matlab to be painfully slow, and therefore decided to write a new set of functions from scratch in Julia. Julia provides an excellent platform for quickly and easily working with very large datasets. With the exception of the plotting tools, the functions in this Julia package run significantly faster than comparable tools available in Matlab.

Features
--------

The following features are provided:

* Parse an OpenStreetMap XML datafile (OSM files)
* Crop maps to specified boundaries
* Convert maps between LLA, ECEF, and ENU coordinates
* Extract highways, buildings, and tagged features from OSM data
* Filter data by various classes

   - Ways suitable for driving, walking, or cycling
   - Freeways, major city streets, residential streets, etc.
   - Accomodations, shops, industry, etc.

* Draw detailed maps using Julia's Winston graphics package with a variety of options
* Compute shortest or fastest driving, cycling, and walking routes using Julia's Graphs package


Package Status
--------------

All the functionality that I personally need for my work is now implemented in this package. Therefore, future updates will depend on GitHub issues (bug reports or feature requests) created by users. Pull requests for additional functionality are very welcome, as well.
