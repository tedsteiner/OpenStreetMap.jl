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

