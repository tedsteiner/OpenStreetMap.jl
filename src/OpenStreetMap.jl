###################################
### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###
###################################

module OpenStreetMap

import LightXML
import Winston
import Graphs

export parseMapXML, getOSMData, getBounds
export plotMap, cropMap!
export findIntersections, nearestNode, segmentHighways
export lla2enu, lla2ecef, ecef2lla, ecef2enu
export roadways, walkways, cycleways, classify
export createGraph, shortestRoute, fastestRoute, distance, routeEdges

include("types.jl")
include("classes.jl")
include("layers.jl")
include("speeds.jl")

include("parseMap.jl")
include("nodes.jl")
include("bounds.jl")
include("highways.jl")
include("features.jl")
include("buildings.jl")

include("crop.jl")
include("plot.jl")
include("intersections.jl")
include("transforms.jl")
include("routing.jl")

end
