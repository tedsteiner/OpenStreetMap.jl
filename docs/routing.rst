Route Planning
==============

OpenStreetMap.jl provides a user-friendly interface to the Graphs.jl package for route planning on transportation networks. Either shortest or fastest routes may be computed using Dijkstra's algorithm. 

Transportation Network
----------------------

In order to plot routes within the map, the streets must first be converted into a transportation network using ``createGraph()``:

.. py:function:: createGraph( nodes, highways, classes, levels )

Inputs:

* ``nodes`` [``Dict{Int,ENU}`` or ``Dict{Int,ECEF}``]: Dictionary of node locations
* ``highways`` [``Dict{Int,Highway}``]: Dictionary of highways
* ``classes`` [``Dict{Int,Int}``]: Dictionary of highway classifications
* ``levels`` [``Set{Integer}``]: Set of highway classification levels allowed for route planning

Output:

* ``Network`` type, containing all data necessary for route planning with Graphs.jl

A transportation network graph can alternatively be created using highway 
"segments" rather than highways. These segments begin and end at intersections, 
eliminating all intermediate nodes, and can greatly speed up route planning.

.. py:function:: createGraph( nodes, segments, intersections )

Inputs:

* ``nodes`` [``Dict{Int,ENU}`` or ``Dict{Int,ECEF}``]: Dictionary of node locations
* ``segments`` [``Array{Segment,1}``]: Array of segments
* ``intersections`` [``Dict{Int,Intersection}``]: Dictionary of intersections, indexed by node ID

Output:

* ``Network`` type, containing all data necessary for route planning with Graphs.jl

Shortest Routes
---------------

Compute the route with the shortest total distance between two nodes.

.. py:function:: shortestRoute( network, node0, node1 )

Inputs:

* ``network`` [``Network``]: Transportation network
* ``node0`` [``Int``]: ID of start node
* ``node1`` [``Int``]: ID of finish node

Outputs:

* ``route_nodes`` [``Array{Int,1}``]: Ordered list of nodes along route
* ``distance`` [``Float64``]: Total route distance

Fastest Routes
--------------

Given estimated typical speeds for each road type, compute the route with the shortest total traversal time between two nodes.

.. py:function:: fastestRoute( network, node0, node1, class_speeds=SPEED_ROADS_URBAN )

Inputs:

* ``network`` [``Network``]: Transportation network
* ``node0`` [``Int``]: ID of start node
* ``node1`` [``Int``]: ID of finish node
* ``class_speeds`` [``Dict{Int,Real}``]: Traversal speed (km/hr) for each road class

Outputs:

* ``route_nodes`` [``Array{Int,1}``]: Ordered list of nodes along route
* ``route_time`` [``Float64``]: Estimated total route time

**Note 1:** A few built-in speed dictionaries are available in ``speeds.jl``. Highway classifications are defined in ``classes.jl``.

**Note 2:** Routing does not account for stoplights, traffic patterns, etc. ``fastestRoute`` merely weights each edge by both distance and typical speed.

Route Distance
--------------

It is often of use to compute the total route distance, which is not returned by ``fastestRoute()``. An additional function is available for this purpose:

.. py:function:: distance( nodes, route )

Inputs:

* ``nodes`` [``Dict{Int,ENU}`` or ``Dict{Int,ECEF}``]: Dictionary of node locations
* ``route`` [``Array{Int,1}``]: Ordered list of nodes along route

Outputs:

* ``distance`` [``Float64``]: Total route distance

For added convenience, ``distance()`` is additionally overloaded for the following inputs, all of which return a Euclidean distance:

.. py:function:: distance( nodes::Dict{Int,ECEF}, node0::Int, node1::Int )
.. py:function:: distance( loc0::ECEF, loc1::ECEF )
.. py:function:: distance( nodes::Dict{Int,ENU}, node0::Int, node1::Int )
.. py:function:: distance( loc0::ENU, loc1::ENU )
.. py:function:: distance( x0, y0, z0, x1, y1, z1 )
