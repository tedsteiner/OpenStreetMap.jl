# Test route planning
module TestRoutes

using OpenStreetMap
using Base.Test
using Graphs

MAP_FILENAME = "tech_square.osm"

# Load and crop map to file bounds
nodes, hwys, builds, feats = getOSMData(MAP_FILENAME, nodes=true, highways=true, buildings=true, features=true)
bounds = getBounds(parseMapXML(MAP_FILENAME))
cropMap!(nodes, bounds, highways=hwys, buildings=builds, features=feats, delete_nodes=true)

# Convert Nodes to ENU Coordinates
nodesENU = lla2enu(nodes, OpenStreetMap.centerBounds(bounds))

# Form transportation network
roads = roadways(hwys)
network = createGraph(nodesENU, hwys, roads, Set(1:8))

@test Graphs.num_vertices(network.g) == 155
@test Graphs.num_edges(network.g) == 273

loc_start = OpenStreetMap.ENU(-5000, 5500, 0)
loc_end = OpenStreetMap.ENU(5500, -4000, 0)

node0 = nearestNode(nodesENU, loc_start, collect(keys(network.v)))
node1 = nearestNode(nodesENU, loc_end, collect(keys(network.v)))

@test_approx_eq nodesENU[node0].east -197.70015977531895
@test_approx_eq_eps nodesENU[node0].north 129.2258444276026 1e-8
@test_approx_eq nodesENU[node1].east 197.70887841015576
@test_approx_eq nodesENU[node1].north -179.66432048909172

# Shortest Route
shortest_route, shortest_distance = shortestRoute(network, node0, node1)
@test length(shortest_route) == 23
@test_approx_eq shortest_distance 658.03056091277
@test shortest_route[1] == node0
@test shortest_route[5] == 61318438
@test shortest_route[10] == 61332097
@test shortest_route[15] == 1053478488
@test shortest_route[20] == 2472339220
@test shortest_route[end] == node1

# Fastest Route
fastest_route, fastest_time = fastestRoute(network, node0, node1)
fastest_distance = OpenStreetMap.distance(nodesENU, fastest_route)
@test length(fastest_route) == 22
@test_approx_eq fastest_distance 724.5817003198007
@test fastest_route[1] == node0
@test fastest_route[5] == 61318438
@test fastest_route[10] == 575440057
@test fastest_route[15] == 1053478486
@test fastest_route[20] == 2472339219
@test fastest_route[end] == node1

# Get route edge list
shortest_edges = routeEdges(network, shortest_route)
@test length(shortest_edges) == 22

fastest_edges = routeEdges(network, fastest_route)
@test length(fastest_edges) == 21

# Get list of all edges in network
edges = OpenStreetMap.getEdges(network)
for k = 1:Graphs.num_edges(network.g)
    @test edges[k].index == k
end
@test edges[10].source.index == 128
@test edges[10].target.index == 154
@test edges[20].source.index == 111
@test edges[30].source.index == 106
@test edges[40].source.index == 9
@test edges[50].source.index == 22

# Form transportation network from segments
intersections, crossings = findIntersections(hwys)
segments = segmentHighways(nodesENU, hwys, intersections, roads, Set(1:8))
segment_network = createGraph(segments, intersections)

node0 = nearestNode(nodesENU, loc_start, collect(keys(segment_network.v)))
node1 = nearestNode(nodesENU, loc_end, collect(keys(segment_network.v)))

# Shortest route
_, shortest_segment_distance = shortestRoute(network, node0, node1)
@test shortest_segment_distance == shortest_distance

# Fastest route
_, fastest_segment_time = fastestRoute(network, node0, node1)
@test fastest_segment_time == fastest_time

# Nodes within Range
loc0 = nodesENU[node0]
filteredENU = filter((k,v)->haskey(network.v,k), nodesENU)
local_indices = nodesWithinRange(filteredENU, loc0, 100.0)
@test length(local_indices) == 4
@test local_indices[1] == 61317384
@test local_indices[2] == 23
@test local_indices[3] == 61317383
@test local_indices[4] == 17

# Nodes within driving distance
start_index = nearestNode(filteredENU, loc0)
node_indices, distances = nodesWithinDrivingDistance(network, start_index, 300.0)
@test length(node_indices) == length(distances)
@test length(node_indices) == 14
@test node_indices[1] == 61318574
@test node_indices[2] == 18
@test node_indices[4] == 17
@test node_indices[7] == 575472710
@test node_indices[9] == 61317383
@test node_indices[11] == 12
@test node_indices[13] == 61318436
@test_approx_eq_eps distances[1] 273.370463 1e-5
@test_approx_eq_eps distances[3] 181.984201 1e-5
@test_approx_eq_eps distances[5] 294.8091389 1e-5
@test_approx_eq_eps distances[6] 124.141919 1e-5
@test_approx_eq_eps distances[8] 49.373168 1e-5
@test_approx_eq_eps distances[11] 237.6051207 1e-5
@test_approx_eq_eps distances[13] 240.895672 1e-5

# Test nodes within driving distance, with multi-start
node_indices, distances = nodesWithinDrivingDistance(network, local_indices, 300.0)
@test length(node_indices) == length(distances)
@test length(node_indices) == 29
@test node_indices[1] ==   61318572
@test node_indices[5] == 270134897
@test node_indices[10] == 61318575
@test node_indices[15] == 61317384
@test node_indices[20] == 270134937
@test node_indices[25] == 61318436
@test node_indices[29] == 61332101
@test_approx_eq_eps distances[1] 293.46982726054546 1e-5
@test_approx_eq_eps distances[5] 296.07515014727875 1e-5
@test_approx_eq_eps distances[10] 239.86445624635402 1e-5
@test_approx_eq_eps distances[15] 0.0 1e-5
@test_approx_eq_eps distances[20] 286.64003818285556 1e-5
@test_approx_eq_eps distances[25] 185.95098954713148 1e-5
@test_approx_eq_eps distances[29] 299.0071494358331 1e-5

# Nodes within driving time
node_indices, distances = nodesWithinDrivingTime(network, start_index, 50.0)
@test length(node_indices) == length(distances)
@test length(node_indices) == 31
@test node_indices[1] == 61318572
@test node_indices[5] == 33
@test node_indices[10] == 270134895
@test node_indices[15] == 575440057
@test node_indices[20] == 61323886
@test node_indices[25] == 473951349
@test node_indices[30] == 986189343
@test_approx_eq_eps distances[1] 45.544798726849216 1e-5
@test_approx_eq_eps distances[5] 48.04166713005169 1e-5
@test_approx_eq_eps distances[10] 44.62973344050917 1e-5
@test_approx_eq_eps distances[15] 44.29039553503941 1e-5
@test_approx_eq_eps distances[20] 33.10080430980987 1e-5
@test_approx_eq_eps distances[25] 45.06680630696164 1e-5
@test_approx_eq_eps distances[30] 6.51756575933207 1e-5

# Test nodes within driving time, with multi-start
node_indices, distances = nodesWithinDrivingDistance(network, local_indices, 50.0)
@test length(node_indices) == length(distances)
@test length(node_indices) == 42
@test node_indices[1] == 575444707
@test node_indices[10] == 270134899
@test node_indices[20] == 30
@test node_indices[30] == 270134936
@test node_indices[40] == 986189343
@test_approx_eq_eps distances[1] 47.89297866535772 1e-5
@test_approx_eq_eps distances[10] 37.96993889800794 1e-5
@test_approx_eq_eps distances[20] 37.96993889800794 1e-5
@test_approx_eq_eps distances[30] 49.33824153819995 1e-5
@test_approx_eq_eps distances[40] 37.52661768605188 1e-5

end # module TestRoutes
