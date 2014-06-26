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
    nodes::Array{Int,1} # List of nodes
end

type Feature
    class::String       # Shop, amenity, crossing, etc.
    detail::String      # Class qualifier
    name::String        # Name
end

type Building
    class::String       # Building type (usually "yes")
    name::String        # Building name (usually unavailable)
    nodes::Array{Int,1} # List of nodes
end

type Intersection
    highways::Set{Int} # Set of highway IDs
end

type Bounds
    min_lat
    max_lat
    min_lon
    max_lon
end

# Transporation network graph data
type Network
    g
    v
    e
    w
    v_inv
    class
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

### Point translators
function getX( lla::LLA )
    return lla.lon
end
function getY( lla::LLA )
    return lla.lat
end
function getX( enu::ENU )
    return enu.east
end
function getY( enu::ENU )
    return enu.north
end

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
        new(a,b,e,e_prime)
    end
end

### Rendering style data
type Style
    color::Uint32
    width::Real
    spec::String
end
Style(x, y) = Style(x, y, "-")
