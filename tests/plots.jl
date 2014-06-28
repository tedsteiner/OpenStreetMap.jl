# Test plotting

using OpenStreetMap
using Base.Test

MAP_FILENAME = "tech_square.osm"

# Load and crop map to file bounds
nodes, hwys, builds, feats = getOSMData( MAP_FILENAME, nodes=true, highways=true, buildings=true, features=true)
bounds = getBounds( parseMapXML( MAP_FILENAME ) )
cropMap!(nodes, bounds, highways=hwys, buildings=builds, features=feats, delete_nodes=true)

roads = roadways( hwys )
peds = walkways( hwys )
cycles = cycleways( hwys )
bldg_classes = classify( builds )
feat_classes = classify( feats )

fignum = plotMap(nodes, highways=hwys, buildings=builds, features=feats, bounds=bounds, width=500, feature_classes=feat_classes, building_classes=bldg_classes, cycleways=cycles, walkways=peds, roadways=roads)

@test fignum == 1
