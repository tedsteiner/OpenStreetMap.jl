Examples
========

Read data from an OSM XML file:

.. code-block:: python

    nodes, hwys, builds, feats = getOSMData(MAP_FILENAME, nodes=true, highways=true, buildings=true, features=true)

    println("Number of nodes: $(length(nodes))")
    println("Number of highways: $(length(hwys))")
    println("Number of buildings: $(length(builds))")
    println("Number of features: $(length(feats))")

Define map boundary and crop:

.. code-block:: python

    bounds = OpenStreetMap.Bounds(42.365, 42.3675, -71.1, -71.094)

    cropMap!(nodes, bounds, highways=hwys, buildings=builds, features=feats, delete_nodes=false)

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

Convert map nodes to ENU coordinates:

.. code-block:: python

    reference = OpenStreetMap.centerBounds(bounds)
    nodesENU = lla2enu(nodes, reference)
    boundsENU = lla2enu(bounds, reference)

Create transportation network:

.. code-block:: python

    network = createGraph(nodesENU, hwys, roads, Set(1:8))

    println("Graph formed with $(Graphs.num_vertices(network.g)) vertices and $(Graphs.num_edges(network.g)) edges.")

Route planning:

.. code-block:: python

    loc_start = OpenStreetMap.ENU(-5000, 5500, 0)
    loc_end = OpenStreetMap.ENU(5500, -4000, 0)

    node0 = nearestNode(nodesENU, loc_start, network.v_inv)
    node1 = nearestNode(nodesENU, loc_end, network.v_inv)
    shortest_route, shortest_distance = shortestRoute(network, node0, node1)

    fastest_route, fastest_time = fastestRoute(network, node0, node1)
    fastest_distance = distance(nodesENU, fastest_route)

    println("Shortest route: $(shortest_distance) m  (Nodes: $(length(shortest_route)))")
    println("Fastest route: $(fastest_distance) m  Time: $(fastest_time/60) min  (Nodes: $(length(fastest_route)))")

Display shortest and fastest routes:

.. code-block:: python

    fignum_shortest = plotMap(nodesENU, highways=hwys, bounds=boundsENU, roadways=roads, route=shortest_route)

    fignum_fastest = plotMap(nodesENU, highways=hwys, bounds=boundsENU, roadways=roads, route=fastest_route)

Extract nearby Nodes (within range)

.. code-block:: python

    loc0 = nodesENU[node0]
    filteredENU = filter((k,v)->haskey(network.v,k), nodesENU)
    local_indices = nodesWithinRange(filteredENU, loc0, 100.0)

Identify Driving Catchment Areas (within limit)

.. code-block:: python

    start_index = nearestNode(filteredENU, loc0)
    node_indices, distances = nodesWithinDrivingDistance(network, local_indices, 300.0)

Alternatively, switch to catchment areas based on driving time, rather than distance

.. code-block:: python

    node_indices, distances = nodesWithinDrivingTime(network, local_indices, 50.0)

Display classified roadways, buildings, and features:

.. code-block:: python

    fignum = plotMap(nodesENU,
                     highways=hwys,
                     buildings=builds,
                     features=feats,
                     bounds=boundsENU,
                     width=1000,
                     feature_classes=feat_classes,
                     building_classes=bldg_classes,
                     roadways=roads)

    Winston.savefig("osm_map.png")

**Note:** Winston currently distorts figures slightly when it saves them. Therefore, whenever equal axes scaling is required, export figures as EPS and rescale them as necessary.

