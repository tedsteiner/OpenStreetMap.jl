### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

type Highway
    id::Int64 # Identification number for OSM
    class::String # Type of highway
    oneway::Bool # True if road is one-way
    name::String # Name, if available
    nodes # List of nodes
end

type Feature
    id::Int64 # ID number for OSM
    class::String # Shop, amenity, crossing, etc.
    detail::String # Class qualifier
    name::String # Name
end

type Building
    id::Int64 # ID number for OSM
    class::String # Building type (usually "yes")
    name::String # Building name (usually unavailable)
    nodes # List of nodes
end

type LatLon
    lat::Float64 # Latitude
    lon::Float64 # Longitude
end

type Intersection
    highways::Set{Int64} # Set of highways
end

type Bounds
    min_lat::Float64
    max_lat::Float64
    min_lon::Float64
    max_lon::Float64
end
