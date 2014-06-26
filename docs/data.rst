
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

``nodes, hwys, builds, feats = getOSMData( MAP_FILENAME, nodes=true, highways=true, buildings=true, features=true)``

**Usage Notes:**
Reading data is generally very fast unless your system runs out of memory. This is because LightXML.jl loads the entire xml file into memory as a tree rather than streaming it. A 150 MB OSM file seems to take up about 2-3 GB of RAM on my machine, so load large files with caution.
