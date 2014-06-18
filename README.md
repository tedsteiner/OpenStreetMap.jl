## OpenStreetMap.jl

This package provides basic functionality for working with [OpenStreetMap](http://www.openstreetmap.org) map data:
* Parse an OpenStreetMap XML datafile (OSM file)
* Extract highways, buildings, and features from an OSM file
* Crop maps to specified boundaries (includes highway interpolation)
* Easily plot a map using Winston

[![Build Status](https://travis-ci.org/tedsteiner/OpenStreetMap.jl.png)](https://travis-ci.org/tedsteiner/OpenStreetMap.jl)

### Setup

Add this package within Julia using:

```
Pkg.add("OpenStreetMap")
```
##### Dependencies
The following packages should automatically be added as "additional packages", if you do not already have them:
* LightXML.jl: Provides the capability to quickly parse OpenStreetMap datafilee
* Winston.jl: Enables basic map plotting

**Note:** LightXML relies on *libxml2*, which is shipped with Mac OS X and many Linux systems. So this package may work out of the box. If not, check whether you have *libxml2* installed and whether *libxml2.so* (for Linux) or *libxml2.dylib* (for Mac) is on your library search path. I have tested it to work out of the box in both OS X 10.9 (Mavericks) and Ubuntu 14.04, but have not yet tried it on Windows.

### Examples
Coming soon!
