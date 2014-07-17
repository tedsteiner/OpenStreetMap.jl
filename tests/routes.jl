# Test route planning

using OpenStreetMap
using Base.Test

MAP_FILENAME = "tech_square.osm"

# Load and crop map to file bounds
nodes, hwys, builds, feats = getOSMData( MAP_FILENAME, nodes=true, highways=true, buildings=true, features=true)
bounds = getBounds( parseMapXML( MAP_FILENAME ) )
cropMap!(nodes, bounds, highways=hwys, buildings=builds, features=feats, delete_nodes=true)

# Convert Nodes to ENU Coordinates
nodesENU = lla2enu( nodes, OpenStreetMap.centerBounds(bounds) )

# Form transportation network
network = createGraph( nodesENU, hwys, roads, Set(1:8...) )

@test Graphs.num_vertices(network.g) == 155
@test Graphs.num_edges(network.g) == 273

loc_start = OpenStreetMap.ENU(-5000,5500,0)
loc_end = OpenStreetMap.ENU(5500,-4000,0)
node0 = nearestNode( nodesENU, loc_start, network.v_inv )
node1 = nearestNode( nodesENU, loc_end, network.v_inv )

@test_approx_eq nodesENU[node0].east -197.70015977531895
@test_approx_eq nodesENU[node0].north 129.2258444276026
@test_approx_eq nodesENU[node1].east 197.70887841015576
@test_approx_eq nodesENU[node1].north -179.66432048909172

# Shortest Route
shortest_route, shortest_distance = shortestRoute( network, node0, node1 )
@test length(shortest_route) == 23
@test_approx_eq shortest_distance 658.03056091277
@test shortest_route[1] == node0
@test shortest_route[5] == 61318438
@test shortest_route[10] == 61332097
@test shortest_route[15] == 1053478488
@test shortest_route[20] == 2472339220
@test shortest_route[end] == node1

# Fastest Route
fastest_route, fastest_time = fastestRoute( network, node0, node1 )
fastest_distance = OpenStreetMap.distance( nodesENU, fastest_route )
@test length(fastest_route) == 22
@test_approx_eq fastest_distance 724.5817003198007
@test fastest_route[1] == node0
@test fastest_route[5] == 61318438
@test fastest_route[10] == 575440057
@test fastest_route[15] == 1053478486
@test fastest_route[20] == 2472339219
@test fastest_route[end] == node1

# Get route edge list
shortest_edges = routeEdges( network, shortest_route )
@test length(shortest_edges) == 22

fastest_edges = routeEdges( network, fastest_route )
@test length(fastest_edges) == 21


