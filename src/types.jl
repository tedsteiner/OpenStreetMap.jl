### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

type Highway
    id::Int # Identification number for OSM
    class::String # Type of highway
    oneway::Bool # True if road is one-way
    name::String # Name, if available
    nodes # List of nodes
end

type Feature
    id::Int # ID number for OSM
    class::String # Shop, amenity, crossing, etc.
    detail::String # Class qualifier
    name::String # Name
end

type Building
    id::Int # ID number for OSM
    class::String # Building type (usually "yes")
    name::String # Building name (usually unavailable)
    nodes # List of nodes
end

type Intersection
    highways::Set{Int} # Set of highways
end

type Bounds
    min_lat
    max_lat
    min_lon
    max_lon
end

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

### World Geodetic Coordinate System of 1984
# Standardized coordinate system for Earth
# Global ellipsoidal reference surface
type WSG84
    a::Float64
    b::Float64
    e::Float64
    e_prime::Float64
    N::Float64

    function WSG84()
        a = 6378137                         # Semi-major axis
        b = 6356752.31424518                # Semi-minor axis
        e = sqrt((a*a - b*b) / (a*a))       # Eccentricity
        e_prime = sqrt((a*a - b*b) / (b*b)) # Second eccentricity
        new(a,b,e,e_prime)
    end
end
