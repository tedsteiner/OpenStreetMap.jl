
Reading OSM Data
================

OpenStreetMap data is available in a variety of formats. However, the easiest and most common to work with is the OSM XML format. OpenStreetMap.jl makes reading data from these files easy and straightforward:

.. py:function:: getOSMData( filename::String [, nodes=false, highways=false, buildings=false, features=false])

Inputs:
  * Required:

    * ``filename`` [``String``]: Filename of OSM datafile.
  * Optional:

    * ``nodes`` [``Bool``]: ``true`` to read node data
    * ``highways`` [``Bool``]: ``true`` to read highway data
    * ``buildings`` [``Bool``]: ``true`` to read building data
    * ``features`` [``Bool``]: ``true`` to read feature data

Outputs:
    * ``nodes`` [``false`` or ``Dict{Int,LLA}``]: Dictionary of node locations
    * ``highways`` [``false`` or ``Dict{Int,Highway}``]: Dictionary of highways
    * ``buildings`` [``false`` or ``Dict{Int,Building}``]: Dictionary of buildings
    * ``features`` [``false`` or ``Dict{Int,Feature}``]: Dictionary of features

These four outputs store all data from the file. ``highways``, ``buildings``, and ``features`` are dictionaries indexed by their OSM ID number, and contain an object of their respective type at each index. “Features” actually represent tags attached to specific ``nodes``, so their ID numbers are the node numbers. The ``Highway`` and ``Building`` types both contain lists of ``nodes`` within them.

**Example Usage:**

.. code-block:: python

    nodes, hwys, builds, feats = getOSMData( MAP_FILENAME, nodes=true, highways=true, buildings=true, features=true)``

**Usage Notes:**
Reading data is generally very fast unless your system runs out of memory. This is because LightXML.jl loads the entire xml file into memory as a tree rather than streaming it. A 150 MB OSM file seems to take up about 2-3 GB of RAM on my machine, so load large files with caution.

Extracting Intersections
------------------------

A simple function is provided to find all highway ends and intersections:

.. py:function:: findIntersections( highways::Dict{Int,Highway} )

The only required input is the highway dictionary returned by "getOSMData()." A 
dictionary of "Intersection" types is returned, intexed by the node ID of the 
intersection.

Working with Segments
---------------------

Usually routing can be simplified to the problem of starting and ending at a specified intersection, rather than any node in a highway. In these cases, we can use "Segments" rather than "Highways" to greatly reduce the computation required to compute routes. Segments are subsets of highways that begin and end on nodes, keep track of their parent highway, and hold all intermediate nodes in storage (allowing them to be converted back to Highway types for plotting or cropping). The following functions extract Segments from Highways and convert Segments to Highways, respectively:

.. py:function:: segmentHighways( highways, intersections, classes, levels=Set(1:10...) )

.. py:function:: highwaySegments( segments::Array{Segment,1} )

**Note:** By default, segmentHighways() converts only the first 10 levels into 
segments. If you wish to exclude certain road classes, you should do so here 
prior to routing. By default, OpenStreetMap.jl uses only 8 road classes, but 
only classes 1-6 represent roads used for typical routing (levels 7 and 8 are 
service and pedestrian roads, such as parking lot entrances and driveways). In 
the United States, roads with class 8 should not be used by cars.
