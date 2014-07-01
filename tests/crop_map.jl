# Test cropping OSM data

using OpenStreetMap
using Base.Test

MAP_FILENAME = "tech_square.osm"

nodes, hwys, builds, feats = getOSMData( MAP_FILENAME, nodes=true, highways=true, buildings=true, features=true)

bounds = OpenStreetMap.Bounds(42.3637,42.3655,-71.0919,-71.0893)
cropMap!(nodes, bounds, highways=hwys, buildings=builds, features=feats, delete_nodes=true)

@test length(nodes) == 198
@test length(hwys) == 16
@test length(builds) == 1
@test length(feats) == 0

@test nodes[5].lat == 42.3637
@test nodes[5].lon == -71.08987031726762

@test nodes[10].lat == 42.3655
@test nodes[10].lon == -71.09133788508164

@test nodes[15].lat == 42.363946909012135
@test nodes[15].lon == -71.0893

