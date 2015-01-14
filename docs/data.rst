
Reading OSM Data
================

OpenStreetMap data is available in a variety of formats. However, the easiest and most common to work with is the OSM XML format. OpenStreetMap.jl makes reading data from these files easy and straightforward:

.. py:function:: getOSMData(filename::String)

Inputs:
  * Required:

    * ``filename`` [``String``]: Filename of OSM datafile.

Outputs:
    * ``nodes`` [``false`` or ``Dict{Int,LLA}``]: Dictionary of node locations
    * ``highways`` [``false`` or ``Dict{Int,Highway}``]: Dictionary of highways
    * ``buildings`` [``false`` or ``Dict{Int,Building}``]: Dictionary of buildings
    * ``features`` [``false`` or ``Dict{Int,Feature}``]: Dictionary of features

These four outputs store all data from the file. ``highways``, ``buildings``, and ``features`` are dictionaries indexed by their OSM ID number, and contain an object of their respective type at each index. “Features” actually represent tags attached to specific ``nodes``, so their ID numbers are the node numbers. The ``Highway`` and ``Building`` types both contain lists of ``nodes`` within them.

**Example Usage:**

.. code-block:: python

    nodes, hwys, builds, feats = getOSMData(MAP_FILENAME)

Extracting Intersections
------------------------

A simple function is provided to find all highway ends and intersections:

.. py:function:: findIntersections(highways::Dict{Int,Highway})

The only required input is the highway dictionary returned by "getOSMData()." A
dictionary of "Intersection" types is returned, intexed by the node ID of the
intersection.

In some cases, such as boulevards and other divided roads, OpenStreetMap represents a street as two one-way highways.  This can result in multiple "intersections" detected per true intersection. If desired, these intersections can be "clustered," replacing these multiple intersection-lets with a single node. This gives a better estimate of the total number of highway intersections in a region. 

To do this, we first "cluster" the highways, by gathering all highways with a common name (note that this is dependent on the quality of street name tags in your source data).  We then search for proximal instances of these highway sets crossing one another. Flag max_dist can be used to change the required proximity of the nodes to be considered an intersection (the default is 15 meters). Note that this proximity is the maximum distance the node can be from the centroid of all nodes in the intersection at the time the node is added. If an intersection involves the same highways as an existing cluster during the search but is further away than max_dist, a new cluster will be formed, initialized at that point.

The code to accomplish this is as follows:

.. code-block:: python 

    highway_sets = findHighwaySets(highways)
    intersection_mapping = findIntersectionClusters(nodes,intersections,highway_sets,max_dist=15)
    replaceHighwayNodes!(highways,intersection_mapping)
    cluster_node_ids = unique(collect(values(intersection_mapping)))

The optional flag "max_dist" is in the units of your "nodes" object. 


Working with Segments
---------------------

Usually routing can be simplified to the problem of starting and ending at a specified intersection, rather than any node in a highway. In these cases, we can use "Segments" rather than "Highways" to greatly reduce the computation required to compute routes. Segments are subsets of highways that begin and end on nodes, keep track of their parent highway, and hold all intermediate nodes in storage (allowing them to be converted back to Highway types for plotting or cropping). The following functions extract Segments from Highways and convert Segments to Highways, respectively:

.. py:function:: segmentHighways(highways, intersections, classes, levels=Set(1:10))

.. py:function:: highwaySegments(segments::Vector{Segment})

**Note:** By default, segmentHighways() converts only the first 10 levels into
segments. If you wish to exclude certain road classes, you should do so here
prior to routing. By default, OpenStreetMap.jl uses only 8 road classes, but
only classes 1-6 represent roads used for typical routing (levels 7 and 8 are
service and pedestrian roads, such as parking lot entrances and driveways). In
the United States, roads with class 8 should not be used by cars.


Downloading OSM Data
====================

Downloading OpenStreetMap data in the form of a .osm file is very easy for a simple square region. However, OpenStreetMap.org provides so many options that it is sometimes a little hard to understand the simple tasks.

For a simple region, you want to use the "OpenStreetMap Overpass API." There are a few mirrors available, but I have had the best luck with the server in Denmark, hence its usage in the example below.

There are a few ways to access the API. Here are a few of them.

OpenStreetMap Interface
-----------------------

On OpenStreetMap.org, there is a big "Export" button at the top. For very small regions, this is the best option, because the region boundary will be embedded in the file for you (so you don't have to record it). Just drag the box around your region and click export. Easy!

If your region is too large, you will usually just get a blank page in your browser without any error messages. If this happens, there is a link below the "Export" button that says "Overpass API." This will very conveniently send your region to the API for an automatic download through that system. Unforunately, this .osm file will not include the boundary information, so you will not be able to use OpenStreetMap.jl's convenient ``getBounds`` function. Otherwise, as far as I can tell, it's the same as clicking the "Export" button.

Overpass API Interface
----------------------

If you're not the type to like easy interfaces like dragging a box around your desired region and clicking a button, then this is the option for you! There are two ways to interact with the API. The syntax is confusing, so we will just download a simple rectangular region and do everything else happily within Julia.

The easist  way to access the API is just directly through the web. The syntax is as follows:

.. code-block:: python

    http://overpass-api.de/api/map?bbox=minLon,minLat,maxLon,maxLat

Be sure to replace minLon, etc., with the decimal latitude and longitudes of your bounding box. This will download the file for you, but it is missing the ".osm" extension (you can add this yourself, if you'd like). You can use this to script downloads, but please don't overload the OpenStreetMap servers, which are donation-supported.


Simulating OSM Street Networks
==============================

OpenStreetMap.jl provides some basic street map simulation capabilities. These are hopefully useful for trying things out, like rouing, in a simple grid with known properties. Only highways can be simulated at this time (not features or buildings.

The basic premise is just that you make a list of north/south roads according to their classes, and another of east/west roads. You then give this to the simulator and it gives you back a list of nodes, highways, and the highway classes, all nicely organized in our OpenStreetMap.jl formats. To keep things simple, all roads are separated by 100 meters from one another.

Here is an example:

.. code-block:: python

    roads_north = [6, 6, 4, 6, 6, 3, 6, 6, 4, 6, 6]
    roads_east = [6, 3, 6, 3, 6]
    nodes, highways, highway_classes = simCityGrid(roads_north, roads_east)


