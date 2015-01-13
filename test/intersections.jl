# Test intersection detection and clustering

module TestIntersections

using OpenStreetMap
using Base.Test
using Compat

import OpenStreetMap: Bounds, centerBounds

MAP_FILENAME = "tech_square.osm"

bounds = Bounds(42.3637, 42.3655, -71.0919, -71.0893)

bounds_ENU = lla2enu(bounds)

nodesLLA, hwys, builds, feats = getOSMData(MAP_FILENAME)
nodes = lla2enu(nodesLLA,centerBounds(bounds))

# Find intersections in map
intersections = findIntersections(hwys)
@test length(intersections) == 91

# Find Highway Sets
highway_sets = findHighwaySets(hwys)
@test length(highway_sets) == 4

# Cluster intersections
intersection_cluster_mapping, intersection_cluster_nodes = findIntersectionClusters(nodes,intersections,highway_sets,max_dist=15)
replaceHighwayNodes!(hwys,intersection_cluster_mapping)
intersections_clustered = findIntersections(hwys)
@test length(intersections_clustered) == 82

end # module TestIntersections


