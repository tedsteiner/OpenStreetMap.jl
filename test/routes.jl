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

end # module TestRoutes
