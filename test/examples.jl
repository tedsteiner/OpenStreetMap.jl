# Test that example workflow from documentation works

module TestExamples

using OpenStreetMap
import Winston

const MAP_FILENAME = "tech_square.osm"

# Read data from an OSM XML file
nodesLLA, highways, buildings, features = getOSMData( MAP_FILENAME )
println("Number of nodes: $(length(nodesLLA))")
println("Number of highways: $(length(highways))")
println("Number of buildings: $(length(buildings))")
println("Number of features: $(length(features))")


# Get bounds from OSM file
# (This is not always available, depending on how OSM data was exported.)
boundsLLA = getBounds(parseMapXML(MAP_FILENAME))


# Convert to ENU coordinates
lla_reference = center(boundsLLA) # Manual reference point for coordinate transform (optional)
nodes = ENU( nodesLLA, lla_reference )
bounds = ENU( boundsLLA, lla_reference )


# Crop map to bounds
cropMap!(nodes, bounds, highways=highways, buildings=buildings, features=features, delete_nodes=false)


# Extract highway classes (note that OpenStreetMap calls all paths “highways”
roads = roadways(highways)
peds = walkways(highways)
cycles = cycleways(highways)
bldg_classes = classify(buildings)
feat_classes = classify(features)


# Find all highway intersections
intersections = findIntersections(highways)


# Segment only specific levels of roadways
# (e.g., freeways through residential streets, levels 1-6)
segments = segmentHighways(nodes, highways, intersections, roads, Set(1:6))


# Create the routing network
network = createGraph(segments, intersections)


# Compute the shortest and fastest routes from point A to B
loc_start = ENU(-5000, 5500, 0)
loc_end = ENU(5500, -4000, 0)

node0 = nearestNode(nodes, loc_start, network)
node1 = nearestNode(nodes, loc_end, network)
shortest_route, shortest_distance = shortestRoute(network, node0, node1)

fastest_route, fastest_time = fastestRoute(network, node0, node1)
fastest_distance = distance(nodes, fastest_route)

println("Shortest route: $(shortest_distance) m  (Nodes: $(length(shortest_route)))")
println("Fastest route: $(fastest_distance) m  Time: $(fastest_time/60) min  (Nodes: $(length(fastest_route)))")


# Display the shortest and fastest routes
fignum_shortest = plotMap(nodes, highways=highways, bounds=bounds, roadways=roads, route=shortest_route)

fignum_fastest = plotMap(nodes, highways=highways, bounds=bounds, roadways=roads, route=fastest_route)


# Extract Nodes near to (within range) our route's starting location:
loc0 = nodes[node0]
filteredENU = filter((k,v)->haskey(network.v,k), nodes)
local_indices = nodesWithinRange(filteredENU, loc0, 100.0)


# Identify Driving Catchment Areas (within limit):
start_index = nearestNode(filteredENU, loc0)
node_indices, distances = nodesWithinDrivingDistance(network, local_indices, 300.0)

node_indices, distances = nodesWithinDrivingTime(network, local_indices, 50.0)

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

end # module TestExamples
