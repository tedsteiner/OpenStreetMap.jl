### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

type Highway
    class::String       # Type of highway
    lanes::Int          # Number of lanes (1 if unspecified)
    oneway::Bool        # True if road is one-way
    sidewalk::String    # Sidewalk classifier, if available
    cycleway::String    # Cycleway classifier, if available
    bicycle::String     # Bicycle classifier, if available
    name::String        # Name, if available
    nodes::Vector{Int}  # List of nodes
end

type Segment
    node0::Int          # Source node ID
    node1::Int          # Target node ID
    nodes::Vector{Int}  # List of nodes falling within node0 and node1
    dist::Real          # Length of the segment
    class::Int          # Class of the segment
    parent::Int         # ID of parent highway
    oneway::Bool        # True if road is one-way
end

type Feature
    class::String       # Shop, amenity, crossing, etc.
    detail::String      # Class qualifier
    name::String        # Name
end

type Building
    class::String       # Building type (usually "yes")
    name::String        # Building name (usually unavailable)
    nodes::Vector{Int}  # List of nodes
end

type Intersection
    highways::Set{Int}  # Set of highway IDs
end
Intersection() = Intersection(Set{Int}())

type HighwaySet # Multiple highways representing a single "street" with a common name
    highways::Set{Int}
end

# Transporation network graph data and helpers to increase routing speed
type Network
    g                                   # Graph object
    v::Dict{Int,Graphs.KeyVertex{Int}}  # (node id) => (graph vertex)
    w::Vector{Float64}                  # Edge weights, indexed by edge id
    class::Vector{Int}                 # Road class of each edge
end

### Rendering style data
type Style
    color::Uint32
    width::Real
    spec::String
end
Style(x, y) = Style(x, y, "-")
