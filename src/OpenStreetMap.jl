###################################
### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###
###################################

module OpenStreetMap

using Reexport
@reexport using Geodesy
using LightXML
using LibExpat
using Winston
using Graphs
using Compat

export parseMapXML, getOSMData, getBounds
export plotMap, cropMap!
export findIntersections, nearestNode, segmentHighways, highwaySegments
export roadways, walkways, cycleways, classify
export createGraph, shortestRoute, fastestRoute, routeEdges
export nodesWithinRange, nodesWithinDrivingDistance, nodesWithinDrivingTime
export findHighwaySets, findIntersectionClusters, replaceHighwayNodes!
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

include("deprecated.jl")

end # module OpenStreetMap
