# Test extracting way, building, and feature classes from OSM data
module TestClasses

using OpenStreetMap
using Base.Test

MAP_FILENAME = "tech_square.osm"

# Load and crop map to file bounds
nodes, hwys, builds, feats = getOSMData(MAP_FILENAME)
bounds = getBounds(parseMapXML(MAP_FILENAME))
cropMap!(nodes, bounds, highways=hwys, buildings=builds, features=feats, delete_nodes=true)

roads = roadways(hwys)
peds = walkways(hwys)
cycles = cycleways(hwys)
bldg_classes = classify(builds)
feat_classes = classify(feats)

@test length(roads) == 38
@test length(peds) == 55
@test length(cycles) == 36
@test length(bldg_classes) == 17
@test length(feat_classes) == 4

for key in keys(feat_classes)
    @test feat_classes[key] == 1
end

end # module TestClasses
