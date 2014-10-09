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
    highways::Set{Int} # Set of highway IDs
end
Intersection() = Intersection(Set{Int}())

type Bounds{T}
    min_y::Float64
    max_y::Float64
    min_x::Float64
    max_x::Float64
end
function Bounds(min_lat, max_lat, min_lon, max_lon)
    if !(-90 <= min_lat <= max_lat <= 90 && -180 <= min_lon <= max_lon <= 180)
        throw(ArgumentError("Bounds out of range of LLA coordinate system. " *
                            "Perhaps you're looking for Bounds{ENU}(...)"))
    end
    Bounds{LLA}(min_lat, max_lat, min_lon, max_lon)
end

# Transporation network graph data and helpers to increase routing speed
type Network
    g                                   # Graph object
    v::Dict{Int,Graphs.KeyVertex{Int}}  # (node id) => (graph vertex)
    w::Vector{Float64}                  # Edge weights, indexed by edge id
    class::Vector{Int}                 # Road class of each edge
end

###################
### Point Types ###
###################

### Point in Latitude-Longitude-Altitude (LLA) coordinates
# Used to store node data in OpenStreetMap XML files
type LLA
    lat
    lon
    alt
end
LLA(lat, lon) = LLA(lat, lon, 0)

### Point in Earth-Centered-Earth-Fixed (ECEF) coordinates
# Global cartesian coordinate system rotating with the Earth
type ECEF
    x
    y
    z
end

### Point in East-North-Up (ENU) coordinates
# Local cartesian coordinate system
# Linearized about a reference point
type ENU
    east
    north
    up
end
ENU(x, y) = ENU(x, y, 0)

### Helper for creating other point types
type XYZ
    x
    y
    z
end
XY(x, y) = XYZ(x, y, 0)

LLA(xyz::XYZ) = LLA(xyz.y, xyz.x, xyz.z)
ENU(xyz::XYZ) = ENU(xyz.x, xyz.y, xyz.z)

### Point translators
getX(lla::LLA) = lla.lon
getY(lla::LLA) = lla.lat

getX(enu::ENU) = enu.east
getY(enu::ENU) = enu.north

### World Geodetic Coordinate System of 1984 (WGS 84)
# Standardized coordinate system for Earth
# Global ellipsoidal reference surface
type WGS84
    a
    b
    e
    e_prime
    N

    function WGS84()
        a = 6378137                         # Semi-major axis
        b = 6356752.31424518                # Semi-minor axis
        e = sqrt((a*a - b*b) / (a*a))       # Eccentricity
        e_prime = sqrt((a*a - b*b) / (b*b)) # Second eccentricity
        new(a, b, e, e_prime)
    end
end

### Rendering style data
type Style
    color::Uint32
    width::Real
    spec::String
end
Style(x, y) = Style(x, y, "-")
