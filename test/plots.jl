# Test plotting
module TestPlots

using OpenStreetMap
using Base.Test
import Winston

MAP_FILENAME = "tech_square.osm"

# Load and crop map to file bounds
nodesLLA, hwys, builds, feats = getOSMData(MAP_FILENAME)
boundsLLA = getBounds(parseMapXML(MAP_FILENAME))
cropMap!(nodesLLA, boundsLLA, highways=hwys, buildings=builds, features=feats, delete_nodes=true)

roads = roadways(hwys)
peds = walkways(hwys)
cycles = cycleways(hwys)
bldg_classes = classify(builds)
feat_classes = classify(feats)

p = plotMap(nodesLLA, highways=hwys, buildings=builds, features=feats, bounds=boundsLLA, width=500, feature_classes=feat_classes, building_classes=bldg_classes, cycleways=cycles, walkways=peds, roadways=roads)

@test typeof(p) == Winston.FramedPlot
@test Winston.getattr(p, "xlabel") == "Longitude (deg)"
@test Winston.getattr(p, "ylabel") == "Latitude (deg)"
@test Winston.getattr(p.x1, "draw_axis") == true
@test Winston.getattr(p.x1, "draw_grid") == false
@test Winston.getattr(p, "xrange") == (-71.0939, -71.0891)
@test Winston.getattr(p, "yrange") == (42.3626, 42.3659)

lla_ref = center(boundsLLA)
nodesENU = ENU(nodesLLA, lla_ref)
boundsENU = ENU(boundsLLA, lla_ref)

p2 = plotMap(nodesENU, highways=hwys, buildings=builds, features=feats, bounds=boundsENU, width=500, feature_classes=feat_classes, building_classes=bldg_classes, cycleways=cycles, walkways=peds, roadways=roads, km=true, fontsize=4)

@test typeof(p2) == Winston.FramedPlot
@test Winston.getattr(p2, "xlabel") == "East (km)"
@test Winston.getattr(p2, "ylabel") == "North (km)"
@test Winston.getattr(p2.x1, "draw_axis") == true
@test Winston.getattr(p2.x1, "draw_grid") == false
@test_approx_eq_eps Winston.getattr(p2, "xrange")[1] -0.19770898045741428 1e-6
@test_approx_eq_eps Winston.getattr(p2, "xrange")[2] 0.19770898045628862 1e-6
@test_approx_eq_eps Winston.getattr(p2, "yrange")[1] -0.18328257005093138 1e-6
@test_approx_eq_eps Winston.getattr(p2, "yrange")[2] 0.18328541309049148 1e-6

end # module TestPlots
