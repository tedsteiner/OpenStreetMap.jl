###################################
### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###
###################################

module OpenStreetMap

import LightXML
import Winston

export parseMapXML
export getNodes, getBounds, getHighways, getBuildings, getFeatures
export plotMap, cropMap!, findIntersections
export lla2enu, lla2ecef, ecef2lla, ecef2enu

include("types.jl")
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

end
