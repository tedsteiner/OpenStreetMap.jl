Working with Data
===============================

This page gives details on the functions provided by OpenStreetMap.jl for working with OSM data.

Cropping Maps
-------------

OSM XML files do not provide sharp edges on boundaries. Also, it is often the case that one wants to focus on one subregion of a large OSM file. A cropping function is provided for these cases:

.. code-block:: python

    function cropMap!(nodes::Dict,
                      bounds::Bounds;
                      highways=nothing,
                      buildings=nothing,
                      features=nothing,
                      delete_nodes::Bool=true)



Classifying Map Elements
------------------------

OpenStreetMap.jl can classify map elements according to the following schemes:
* Roadways [8 levels]
* Cycleways [4 levels]
* Walkways [4 levels]
* Building Types [5 levels]
* Feature Types [7 levels]

Each of these schemes classifies map elements using their OSM tags according to multiple levels. The definitions of these levels is encoded in ``classes.jl``.

The following functions take their respective map element lists as the single parameter and output a classification dictionary of type ``Dict{Int,Int}``. The ``keys`` of the dictionary are the highway ID numbers, and the ``values`` provide the classification of that map element.

* ``roadways(highways)``
* ``walkways(highways)``
* ``cycleways(highways)``
* ``classify(buildings)``
* ``classify(features)``

These classification dictionaries can be used for both route planning and map plotting.

Converting Map Coordinate Systems
---------------------------------

OpenStreetMap.jl is capable of converting map data between LLA, ECEF, and ENU coordinates (see "Data Types") for definitions of these standard coordinates. Because point location data is ONLY stored in the ``nodes`` dictionary (type ``Dict{Int,Point-Type}``), only this object needs to be converted. Note that Bounds objects also need to be converted, although they don't technically store map data. The following functions can be used to convert between coordinate systems:

* ``ECEF(nodes::Dict{Int,LLA})``
* ``LLA(nodes::Dict{Int,ECEF})``
* ``ENU(nodes::Dict{Int,ECEF}, reference::LLA)``
* ``ENU(nodes::Dict{Int,LLA}, reference::LLA)``

East-North-Up coordinates require an additional input parameter, ``reference``, which gives the origin of the ENU coordinate system. LLA and ECEF coordinates both have their origins fixed at the center of the earth.

Coordinate System Selection
^^^^^^^^^^^^^^^^^^^^^^^^^^^

An effort has been made to allow users to work in the coordinate system of their choice. However, often times a specific coordinate system might not make sense for a given task, and thus functionality has not been implemented for it. Below are a few examples:

* Map cropping and plotting do not work in ECEF coordinates (these operations are fundamentally 2D operations, which is convenient only for LLA and ENU coordinates)
* Route planning does not work in LLA coordinates (spherical distances have note been implemented)
