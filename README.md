## OpenStreetMap.jl

[![Build Status](https://travis-ci.org/tedsteiner/OpenStreetMap.jl.svg)](https://travis-ci.org/tedsteiner/OpenStreetMap.jl)
[![Coverage Status](http://img.shields.io/coveralls/tedsteiner/OpenStreetMap.jl.svg)](https://coveralls.io/r/tedsteiner/OpenStreetMap.jl)
[![OpenStreetMap](http://pkg.julialang.org/badges/OpenStreetMap_release.svg)](http://pkg.julialang.org/?pkg=OpenStreetMap&ver=release)
[![OpenStreetMap](http://pkg.julialang.org/badges/OpenStreetMap_nightly.svg)](http://pkg.julialang.org/?pkg=OpenStreetMap&ver=nightly)

This package provides basic functionality for parsing, viewing, and working with [OpenStreetMap](http://www.openstreetmap.org) map data. The package is intended mainly for researchers who want to incorporate this rich, global data into their work, and has been designed with both speed and simplicity in mind, especially for those who might be new to Julia.

**Note:** Our automated tests currently fail on Julia 0.4, but these problems appear to be contained to the test system and are caused by a dependent package. OpenStreetMap.jl should run without issue on both Julia 0.3 and 0.4.

### Capabilities
* Parse an [OpenStreetMap XML datafile](http://wiki.openstreetmap.org/wiki/OSM_XML) (OSM files)
* Crop maps to specified boundaries
* [Convert maps](https://en.wikipedia.org/wiki/Geographic_coordinate_conversion)
  between LLA, ECEF, and ENU coordinates
* Extract highways, buildings, and tagged features from OSM data
* Filter data by various classes:
  * Ways suitable for driving, walking, or cycling
  * Freeways, major city streets, residential streets, etc.
  * Accommodations, shops, industry, etc.
* Draw detailed maps using Julia's [Winston](https://github.com/nolta/Winston.jl) graphics package
  with a variety of options
* Compute shortest or fastest driving, cycling, and walking routes using Julia's Graphs package

### Examples
[This gallery](http://imgur.com/a/28l5K) of map examples shows plotting and routing capabilities of the OpenStreetMap package. All displayed images were created using only OpenStreetMap.jl. For example:
##### Street map of Boston, Massachusetts:
[![Boston](http://i.imgur.com/1pofvuP.png)](http://imgur.com/a/28l5K#0)

### Documentation
[OpenStreetMap.jl documentation](http://openstreetmapjl.readthedocs.org/en/stable/) is hosted by ReadTheDocs.

### Setup

Add this package within Julia using:
```
Pkg.add("OpenStreetMap")
```

##### Dependencies
The following packages will automatically be added as "additional packages", if you do not already have them:
* Geodesy.jl: Map coordinate transforms, formerly part of OpenStreetMap.jl
* LightXML.jl: parsing OpenStreetMap datafiles
* LibExpat.jl: streaming OpenStreetMap datafiles
* Winston.jl: map plotting
* Graphs.jl: map routing

**Note:** LightXML.jl relies on *libxml2*, which is shipped with Mac OS X and many Linux systems. So this package may work out of the box. If not, check whether you have *libxml2* installed and whether *libxml2.so* (for Linux) or *libxml2.dylib* (for Mac) is on your library search path. I have tested it to work out of the box in Mac OS X 10.9 and 10.10 (Mavericks and Yosemite), Ubuntu 14.04, and Windows 7. Winston.jl has a few additional dependencies, which it should resolve automatically. All other code is written in native Julia.

### Package Status and Contributions
All the functionality that I personally need for my work is now implemented in this package, and I am running out of ideas for additional functionality. Therefore, future updates will mostly depend on GitHub issues (bug reports or feature requests) created by users. Pull requests for additional functionality are very welcome, as well.

If you use this package, please feel free to send me feedback on how I might improve it's usability and documentation.
