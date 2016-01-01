# Test route planning
module TestRoutes

using OpenStreetMap
using Base.Test
using Graphs

MAP_FILENAME = "tech_square.osm"

# Load and crop map to file bounds
nodes, hwys, builds, feats = getOSMData(MAP_FILENAME)
bounds = getBounds(parseMapXML(MAP_FILENAME))
cropMap!(nodes, bounds, highways=hwys, buildings=builds, features=feats, delete_nodes=true)

# Convert Nodes to ENU Coordinates
nodesENU = ENU(nodes, center(bounds))

# Form transportation network
roads = roadways(hwys)
network = createGraph(nodesENU, hwys, roads, Set(1:8))

@test Graphs.num_vertices(network.g) == 155
@test Graphs.num_edges(network.g) == 273

loc_start = ENU(-5000, 5500, 0)
loc_end = ENU(5500, -4000, 0)

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
fastest_distance = distance(nodesENU, fastest_route)
@test length(fastest_route) == 22
@test_approx_eq fastest_distance 724.5817003198007
@test fastest_route[1] == node0
@test fastest_route[5] == 61318438
@test fastest_route[10] == 575440057
@test fastest_route[15] == 1053478486
@test fastest_route[20] == 2472339219
@test fastest_route[end] == node1

# Empty route
@test distance(nodesENU, Int[]) == Inf

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
#=
@test edges[10].source.index == 128
@test edges[10].target.index == 154
@test edges[20].source.index == 111
@test edges[30].source.index == 106
@test edges[40].source.index == 9
@test edges[50].source.index == 22
=#

# Form transportation network from segments
intersections = findIntersections(hwys)
segments = segmentHighways(nodesENU, hwys, intersections, roads, Set(1:8))
segment_network = createGraph(segments, intersections)

node0 = nearestNode(nodesENU, loc_start, segment_network)
node1 = nearestNode(nodesENU, loc_end, segment_network)

# Shortest route
_, shortest_segment_distance = shortestRoute(segment_network, node0, node1)
@test_approx_eq shortest_segment_distance shortest_distance

# Fastest route
_, fastest_segment_time = fastestRoute(segment_network, node0, node1)
@test_approx_eq fastest_segment_time fastest_time

# Form transportation networks with directions reversed
r_network = createGraph(nodesENU, hwys, roads, Set(1:8), true)
r_segment_network = createGraph(segments, intersections, true)

# Reverse routes over reversed network
_, r_shortest_distance = shortestRoute(r_network, node1, node0)
_, r_fastest_time = fastestRoute(r_network, node1, node0)
@test_approx_eq r_shortest_distance shortest_distance
@test_approx_eq r_fastest_time fastest_time

# Reverse routes over reversed segment network
_, r_shortest_segment_distance = shortestRoute(r_segment_network, node1, node0)
_, r_fastest_segment_time = fastestRoute(r_segment_network, node1, node0)
@test_approx_eq r_shortest_segment_distance shortest_distance
@test_approx_eq r_fastest_segment_time fastest_time

# Nodes within Range
loc0 = nodesENU[node0]
filteredENU = filter((k,v)->haskey(network.v,k), nodesENU)
local_indices = nodesWithinRange(filteredENU, loc0, 100.0)
@test length(local_indices) == 3
for index in [61317384, 61317383]
    @test index in local_indices
end

# Nodes within driving distance
start_index = nearestNode(filteredENU, loc0)
node_indices, distances = nodesWithinDrivingDistance(network, start_index, 300.0)
@test length(node_indices) == length(distances)
@test length(node_indices) == 14
for index in [61318574, 575472710, 61317383, 61318436]
    @test index in node_indices
end
for dist in distances
    @test 0.0 <= dist <= 300.0
end

# Test nodes within driving distance, with multi-start
node_indices, distances = nodesWithinDrivingDistance(network, local_indices, 300.0)
@test length(node_indices) == length(distances)
@test length(node_indices) == 29
for index in [61318572, 270134897, 61318575, 61317384, 270134937, 61318436, 61332101]
    @test index in node_indices
end
for dist in distances
    @test 0.0 <= dist <= 300.0
end

# Nodes within driving time
node_indices, distances = nodesWithinDrivingTime(network, start_index, 50.0)
@test length(node_indices) == length(distances)
@test length(node_indices) == 30
for index in [61318572, 270134895, 575440057, 61323886, 473951349, 986189343]
    @test index in node_indices
end
for dist in distances
    @test 0.0 <= dist <= 50.0
end

# Test nodes within driving time, with multi-start
node_indices, distances = nodesWithinDrivingTime(network, local_indices, 50.0)
@test length(node_indices) == length(distances)
@test length(node_indices) == 41
for index in [575444707, 270134899, 270134936, 986189343]
    @test index in node_indices
end
for dist in distances
    @test 0.0 <= dist <= 50.0
end

end # module TestRoutes
