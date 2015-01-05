###################################
### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###
###################################

module OpenStreetMap

import LightXML
import LibExpat
import Winston
import Graphs
import Compat

export parseMapXML, getOSMData, getBounds
export plotMap, cropMap!
export findIntersections, nearestNode, segmentHighways, highwaySegments
export lla2enu, lla2ecef, ecef2lla, ecef2enu
export roadways, walkways, cycleways, classify
export createGraph, shortestRoute, fastestRoute, distance, routeEdges
export nodesWithinRange, nodesWithinDrivingDistance, nodesWithinDrivingTime
export simCityGrid

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

include("simulate.jl")

end # module OpenStreetMap
