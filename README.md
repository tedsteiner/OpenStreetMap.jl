## OpenStreetMap.jl

This package provides basic functionality for working with [OpenStreetMap](http://www.openstreetmap.org) map data:
* Parse an OpenStreetMap XML datafile (OSM file)
* Extract highways, buildings, and features from an OSM file
* Crop maps to specified boundaries (includes highway interpolation)
* Easily plot a map using Winston

### Setup

While this package is in early development, you may checkout *OpenStreetMap* from this repo using:

```
Pkg.add("git://github.com/tedsteiner/OpenStreetMap.jl.git")
```
Dependencies of this package are LightXML.jl and Winston.jl. LightXML provides the capability to quickly parse OpenStreetMap datafilee, and Winston enables basic map plotting.

**Note:** LightXML relies on the library *libxml2* to work, which is shipped with Mac OS X and many Linux systems. So this package may work out of the box. If not, you may check whether *libxml2* has been in your system and whether *libxml2.so* (for Linux) or *libxml2.dylib* (for Mac) is on your library search path.

[![Build Status](https://travis-ci.org/tedsteiner/OpenStreetMap.jl.png)](https://travis-ci.org/tedsteiner/OpenStreetMap.jl)
