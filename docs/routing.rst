Road Network Analysis
=====================

OpenStreetMap.jl provides a user-friendly interface to the Graphs.jl package for route planning on transportation networks. Either shortest or fastest routes may be computed using Dijkstra's algorithm. In addition, driving catchment areas may be computed using Bellman Ford's algorithm.

Transportation Network
----------------------

In order to plot routes within the map, the streets must first be converted into a transportation network using ``createGraph()``:

.. py:function:: createGraph(nodes, highways, classes, levels)

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

.. py:function:: createGraph(segments, intersections)

Inputs:

* ``segments`` [``Vector{Segment}``]: Vector of segments
* ``intersections`` [``Dict{Int,Intersection}``]: Dictionary of intersections, indexed by node ID

Output:

* ``Network`` type, containing all data necessary for route planning with Graphs.jl

Route Planning
--------------

Shortest Routes
^^^^^^^^^^^^^^^
Compute the route with the shortest total distance between two nodes.

.. py:function:: shortestRoute(network, node0, node1)

Inputs:

* ``network`` [``Network``]: Transportation network
* ``node0`` [``Int``]: ID of start node
* ``node1`` [``Int``]: ID of finish node

Outputs:

* ``route_nodes`` [``Vector{Int}``]: Ordered list of nodes along route
* ``distance`` [``Float64``]: Total route distance

Fastest Routes
^^^^^^^^^^^^^^

Given estimated typical speeds for each road type, compute the route with the shortest total traversal time between two nodes.

.. py:function:: fastestRoute(network, node0, node1, class_speeds=SPEED_ROADS_URBAN)

Inputs:

* ``network`` [``Network``]: Transportation network
* ``node0`` [``Int``]: ID of start node
* ``node1`` [``Int``]: ID of finish node
* ``class_speeds`` [``Dict{Int,Real}``]: Traversal speed (km/hr) for each road class

Outputs:

* ``route_nodes`` [``Vector{Int}``]: Ordered list of nodes along route
* ``route_time`` [``Float64``]: Estimated total route time

**Note 1:** A few built-in speed dictionaries are available in ``speeds.jl``. Highway classifications are defined in ``classes.jl``.

**Note 2:** Routing does not account for stoplights, traffic patterns, etc. ``fastestRoute`` merely weights each edge by both distance and typical speed.

Route Distance
^^^^^^^^^^^^^^

It is often of use to compute the total route distance, which is not returned by ``fastestRoute()``. An additional function is available for this purpose:

.. py:function:: distance(nodes, route)

Inputs:

* ``nodes`` [``Dict{Int,ENU}`` or ``Dict{Int,ECEF}``]: Dictionary of node locations
* ``route`` [``Vector{Int}``]: Ordered list of nodes along route

Outputs:

* ``distance`` [``Float64``]: Total route distance

For added convenience, ``distance()`` is additionally overloaded for the following inputs, all of which return a Euclidean distance:

.. py:function:: distance(nodes::Dict{Int,ECEF}, node0::Int, node1::Int)
.. py:function:: distance(loc0::ECEF, loc1::ECEF)
.. py:function:: distance(nodes::Dict{Int,ENU}, node0::Int, node1::Int)
.. py:function:: distance(loc0::ENU, loc1::ENU)
.. py:function:: distance(x0, y0, z0, x1, y1, z1)

Edge Extraction
^^^^^^^^^^^^^^^

``shortestRoute()`` and ``fastestRoute()`` both return a list of nodes, which
comprises the route. ``routeEdges()`` can then convert this list of nodes into
the list of edges, if desired:

.. py:function:: routeEdges(network::Network, route::Vector{Int})

The output is a list of edge indices with type Vector{Int}.

Driving Regions
---------------

In addition to providing individual routes, the following functions can also be used for retrieving the set of nodes that are within a driving distance limit from a given starting point.

Drive Distance Regions
^^^^^^^^^^^^^^^^^^^^^^

.. py:function:: nodesWithinDrivingDistance(network, start, limit=Inf)

Inputs:

* ``network`` [``Network``]: Transportation network
* ``start`` [``Int`` or ``Vector{Int}``]: ID(s) of start node(s)
* ``limit`` [``Float64``]: Driving Distance limit from start node(s)

Outputs:

* ``node_indices`` [``Vector{Int}``]: Unordered list of indices of nodes within the driving distance limit
* ``distances`` [``Float64``]: Unordered list of distances corresponding to the nodes in ``node_indices``

**Note 1:** A few built-in speed dictionaries are available in ``speeds.jl``. Highway classifications are defined in ``classes.jl``.

**Note 2:** Routing does not account for stoplights, traffic patterns, etc. Each edge is weighted by its distance.


Drive Time Regions
^^^^^^^^^^^^^^^^^^

.. py:function:: nodesWithinDrivingTime(network, start, limit=Inf, class_speeds=SPEED_ROADS_URBAN)

Inputs:

* ``network`` [``Network``]: Transportation network
* ``start`` [``Int`` or ``Vector{Int}`` or ``ENU``]: ID(s) of start node(s), or any ``ENU`` location
* ``limit`` [``Float64``]: Driving time limit from start node(s)
* ``class_speeds`` [``Dict{Int,Real}``]: Traversal speed (km/hr) for each road class

Outputs:

* ``node_indices`` [``Vector{Int}``]: Unordered list of indices of nodes within the driving time limit
* ``timings`` [``Float64``]: Unordered list of driving timings corresponding to the nodes in ``node_indices``

**Note 1:** A few built-in speed dictionaries are available in ``speeds.jl``. Highway classifications are defined in ``classes.jl``.

**Note 2:** Routing does not account for stoplights, traffic patterns, etc. Each edge is weighted by both distance and typical speed.