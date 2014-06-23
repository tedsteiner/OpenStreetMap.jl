###################################
### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###
###################################

module OpenStreetMap

import LightXML
import Winston

export parseMapXML, getOSMData
export getNodes, getBounds, getHighways, getBuildings, getFeatures
export plotMap
export cropMap!
export findIntersections
export lla2enu, lla2ecef, ecef2lla, ecef2enu
export roadways, walkways, cycleways, classify
export highwayVertices

include("types.jl")
include("classes.jl")
include("layers.jl")

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
