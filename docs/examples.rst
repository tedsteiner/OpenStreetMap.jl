Examples
========

The following example walks through a sample workflow using OpenStreetMap.jl. This page does not cover all functionality available in OpenStreetMap.jl, but hopefully helps new users get started quickly. See also "test/examples.jl" for all of these examples together in a single Julia file.

Read data from an OSM XML file:

.. code-block:: python

    nodesLLA, highways, buildings, features = getOSMData(MAP_FILENAME)

    println("Number of nodes: $(length(nodesLLA))")
    println("Number of highways: $(length(highways))")
    println("Number of buildings: $(length(buildings))")
    println("Number of features: $(length(features))")


Define map boundary:

.. code-block:: python

    boundsLLA = Bounds(42.365, 42.3675, -71.1, -71.094)


Define reference point and convert to ENU coordinates:

.. code-block:: python

    lla_reference = center(boundsLLA)
    nodes = ENU(nodesLLA, lla_reference)
    bounds = ENU(boundsLLA, lla_reference)


Crop map to boundary:

.. code-block:: python

    cropMap!(nodes, bounds, highways=highways, buildings=buildings, features=features, delete_nodes=false)


Find highway intersections:

.. code-block:: python

    inters = findIntersections(hwys)

    println("Found $(length(inters)) intersections.")


Extract map components and classes:

.. code-block:: python

    roads = roadways(hwys)
    peds = walkways(hwys)
    cycles = cycleways(hwys)
    bldg_classes = classify(builds)
    feat_classes = classify(feats)


Convert map nodes to East-North-Up (ENU) coordinates:

.. code-block:: python

    reference = center(bounds)
    nodesENU = ENU(nodes, reference)
    boundsENU = ENU(bounds, reference)


Extract highway classes (note that OpenStreetMap calls paths of any form "highways"):

.. code-block:: python

    roads = roadways(highways)
    peds = walkways(highways)
    cycles = cycleways(highways)
    bldg_classes = classify(buildings)
    feat_classes = classify(features)
    

Find all highway intersections:

.. code-block:: python

    intersections = findIntersections(highways)
    
    
Segment only specific levels of roadways (e.g., freeways (class 1) through residential streets (class 6)):

.. code-block:: python

    segments = segmentHighways(nodes, highways, intersections, roads, Set(1:6))


Create transportation network from highway segments:

.. code-block:: python

    network = createGraph(segments, intersections)


Compute the shortest and fastest routes from point A to B:

.. code-block:: python

    loc_start = ENU(-5000, 5500, 0)
    loc_end = ENU(5500, -4000, 0)

    node0 = nearestNode(nodes, loc_start, network)
    node1 = nearestNode(nodes, loc_end, network)
    shortest_route, shortest_distance = shortestRoute(network, node0, node1)

    fastest_route, fastest_time = fastestRoute(network, node0, node1)
    fastest_distance = distance(nodes, fastest_route)

    println("Shortest route: $(shortest_distance) m  (Nodes: $(length(shortest_route)))")
    println("Fastest route: $(fastest_distance) m  Time: $(fastest_time/60) min  (Nodes: $(length(fastest_route)))")


Display the shortest and fastest routes:

.. code-block:: python

    fignum_shortest = plotMap(nodesENU, highways=hwys, bounds=boundsENU, roadways=roads, route=shortest_route)

    fignum_fastest = plotMap(nodesENU, highways=hwys, bounds=boundsENU, roadways=roads, route=fastest_route)


Extract Nodes near to (within range) our route's starting location:

.. code-block:: python

    loc0 = nodes[node0]
    filteredENU = filter((k,v)->haskey(network.v,k), nodes)
    local_indices = nodesWithinRange(filteredENU, loc0, 100.0)


Identify Driving Catchment Areas (within limit):

.. code-block:: python

    start_index = nearestNode(filteredENU, loc0)
    node_indices, distances = nodesWithinDrivingDistance(network, local_indices, 300.0)


Alternatively, switch to catchment areas based on driving time, rather than distance:

.. code-block:: python

    node_indices, distances = nodesWithinDrivingTime(network, local_indices, 50.0)


Display classified roadways, buildings, and features:

.. code-block:: python

    fignum = plotMap(nodes,
                     highways=highways,
                     buildings=buildings,
                     features=features,
                     bounds=bounds,
                     width=500,
                     feature_classes=feat_classes,
                     building_classes=bldg_classes,
                     roadways=roads)

    Winston.savefig("osm_map.png")

**Note:** Winston currently distorts figures slightly when it saves them. Therefore, whenever equal axes scaling is required, export figures as EPS and rescale them as necessary.

