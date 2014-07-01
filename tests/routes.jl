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


println("node23 = $(nodesENU[23])")
println("node23 = $(nodes[23])")
println("node21 = $(nodesENU[21])")
println("node21 = $(nodes[21])")
println("node0 = $(node0)")
println("node1 = $(node1)")
println("node3 = $(nodesENU[3])")
println("node13 = $(nodesENU[13])")

println("Nodes 1-5:")
println(nodes[1])
println(nodes[2])
println(nodes[3])
println(nodes[4])
println(nodes[5])
println("Nodes 6-10:")
println(nodes[6])
println(nodes[7])
println(nodes[8])
println(nodes[9])
println(nodes[10])
println("Nodes 11-15:")
println(nodes[11])
println(nodes[12])
println(nodes[13])
println(nodes[14])
println(nodes[15])
println("Nodes 16-20:")
println(nodes[16])
println(nodes[17])
println(nodes[18])
println(nodes[19])
println(nodes[20])
println("Nodes 21-23:")
println(nodes[21])
println(nodes[22])
println(nodes[23])

@test nodes[1].lat == 42.36406295693916
@test nodes[1].lon == -71.0891
@test nodes[2].lat == 42.3659
@test nodes[2].lon == -71.09192951343779
@test nodes[3].lat == 42.36263254815073
@test nodes[3].lon == -71.0891
@test nodes[4].lat == 42.3659
@test nodes[4].lon == -71.09236911508953
@test nodes[5].lat == 42.36334113794772
@test nodes[5].lon == -71.0891
@test nodes[10].lat == 42.3659
@test nodes[10].lon == -71.08925363926788
@test nodes[15].lat == 42.3659
@test nodes[15].lon == -71.0920064595775

@test node0 == 21
@test node1 == 3

# Shortest Route
shortest_route, shortest_distance = shortestRoute( network, node0, node1 )
@test length(shortest_route) == 23
@test shortest_distance == 658.03056091277
@test shortest_route[1] == 21
@test shortest_route[5] == 61318438
@test shortest_route[10] == 61332097
@test shortest_route[15] == 1053478488
@test shortest_route[20] == 2472339220
@test shortest_route[end] == 3

# Fastest Route
fastest_route, fastest_time = fastestRoute( network, node0, node1 )
fastest_distance = OpenStreetMap.distance( nodesENU, fastest_route )
@test length(fastest_route) == 22
@test fastest_distance == 724.5817003198007
@test fastest_route[1] == 21
@test fastest_route[5] == 61318438
@test fastest_route[10] == 575440057
@test fastest_route[15] == 1053478486
@test fastest_route[20] == 2472339219
@test fastest_route[end] == 3

# Get route edge list
shortest_edges = routeEdges( network, shortest_route )
@test length(shortest_edges) == 22
@test shortest_edges[5] == 26
@test shortest_edges[10] == 45
@test shortest_edges[15] == 182
@test shortest_edges[20] == 111

fastest_edges = routeEdges( network, fastest_route )
@test length(fastest_edges) == 21
@test fastest_edges[5] == 26
@test fastest_edges[10] == 16
@test fastest_edges[15] == 184
@test fastest_edges[20] == 71

