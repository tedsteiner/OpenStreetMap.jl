## OpenStreetMap.jl

This package provides basic functionality for parsing, viewing, and working with [OpenStreetMap](http://www.openstreetmap.org) map data. The package is intended mainly for researchers who want to incorporate this rich, global data into their work, and has been designed with both speed and simplicity in mind, especially for those who might be new to Julia.

Basic capabilities include:
* Parse an OpenStreetMap XML datafile (OSM files)
* Crop maps to specified boundaries
* Convert maps between LLA, ECEF, and ENU coordinates
* Extract highways, buildings, and tagged features from OSM data
* Filter data by various classes
  * Ways suitable for driving, walking, or cycling
  * Freeways, major city streets, residential streets, etc.
  * Accomodations, shops, industry, etc.
* Draw detailed maps using Julia's Winston graphics package with a variety of options
* Compute shortest or fastest driving, cycling, and walking routes using Julia's Graphs package

[![Boston](http://i.imgur.com/1pofvuP.png)](http://imgur.com/a/28l5K#0)

[![Build Status](https://travis-ci.org/tedsteiner/OpenStreetMap.jl.png)](https://travis-ci.org/tedsteiner/OpenStreetMap.jl)

### Setup

Add this package within Julia using:
```
Pkg.add("OpenStreetMap")
```
##### Dependencies
The following packages should automatically be added as "additional packages", if you do not already have them:
* LightXML.jl: parsing OpenStreetMap datafiles
* Winston.jl: map plotting
* Graphs.jl: map routing

**Note:** LightXML.jl relies on *libxml2*, which is shipped with Mac OS X and many Linux systems. So this package may work out of the box. If not, check whether you have *libxml2* installed and whether *libxml2.so* (for Linux) or *libxml2.dylib* (for Mac) is on your library search path. I have tested it to work out of the box in Mac OS X 10.9 (Mavericks), Ubuntu 14.04, and Windows 7. Winston.jl has a few additional dependencies, which it should resolve automatically. All other code is written in native Julia.

### Examples
Coming soon!
