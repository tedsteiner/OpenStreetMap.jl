# Test city simulation
module TestSimCity

using OpenStreetMap
using Base.Test

roads_north = [3, 5, 7]
roads_east = [3, 4, 5, 4]
nodes, highways, roads = simCityGrid(roads_north, roads_east)

@test length(nodes) == 12
@test length(highways) == 7
@test length(roads) == length(highways)

# Test node simulation
@test nodes[1].east == 100
@test nodes[1].north == 100
@test nodes[7].east == 200
@test nodes[7].north == 300
@test nodes[10].east == 300
@test nodes[10].north == 200

# Test highway simulation
@test highways[1].name == "North_1"
@test highways[5].name == "East_2"
@test highways[2].nodes == [5, 6, 7, 8]
@test highways[4].nodes == [1, 5, 9]
@test highways[6].nodes == [3, 7, 11]

# Test road classes
@test roads[1] == roads_north[1]
@test roads[3] == roads_north[3]
@test roads[5] == roads_east[2]
@test roads[7] == roads_east[4]

end # module TestSimCity
