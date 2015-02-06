# Test intersection detection and clustering

module TestIntersections

using OpenStreetMap
using Base.Test
using Compat

MAP_FILENAME = "tech_square.osm"

bounds = Bounds(42.3637, 42.3655, -71.0919, -71.0893)

bounds_ENU = ENU(bounds)

nodesLLA, hwys, builds, feats = getOSMData(MAP_FILENAME)
nodes = ENU(nodesLLA, center(bounds))

# Find intersections in map
intersections = findIntersections(hwys)
@test length(intersections) == 91

# Find Highway Sets
highway_sets = findHighwaySets(hwys)
@test length(highway_sets) == 4

# Cluster intersections
intersection_cluster_mapping = findIntersectionClusters(nodes,intersections,highway_sets,max_dist=15)
intersection_clusters = unique(collect(values(intersection_cluster_mapping)))
@test length(intersection_clusters) == 5

# Replace Nodes in Highways
replaceHighwayNodes!(hwys,intersection_cluster_mapping)
intersections_clustered = findIntersections(hwys)
@test length(intersections_clustered) == 82

# Check how many semi-redundant intersections we were able to remove
removed = length(intersections) - length(intersections_clustered)
@test removed == 9

end # module TestIntersections


