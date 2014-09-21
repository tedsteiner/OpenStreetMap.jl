### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for map coordinate transformations ###

###############################################
### Conversion from LLA to ECEF coordinates ###
###############################################

# For single-point calculations
function lla2ecef(lla::LLA)
    datum = WGS84() # Get WGS84 datum

    lla2ecef(lla, datum)
end

# For multi-point loops
function lla2ecef(lla::LLA, d::WGS84)
    lat = lla.lat
    lon = lla.lon
    alt = lla.alt

    N = d.a / sqrt(1 - d.e*d.e * sind(lat)^2)   # Radius of curvature (meters)

    x = (N + alt) * cosd(lat) * cosd(lon)
    y = (N + alt) * cosd(lat) * sind(lon)
    z = (N * (1 - d.e*d.e) + alt) * sind(lat)

    return ECEF(x, y, z)
end

# For dictionary of nodes
function lla2ecef(nodes::Dict{Int,LLA})
    nodesECEF = Dict{Int,ECEF}()
    datum = WGS84()

    for key in keys(nodes)
        nodesECEF[key] = lla2ecef(nodes[key], datum)
    end

    return nodesECEF
end


###############################################
### Conversion from ECEF to LLA coordinates ###
###############################################

# For single-point calculations
function ecef2lla(ecef::ECEF)
    datum = WGS84() # Get WGS84 datum

    return ecef2lla(ecef, datum)
end

# For multi-point loops
function ecef2lla(ecef::ECEF, d::WGS84)
    x = ecef.x
    y = ecef.y
    z = ecef.z

    p = sqrt(x*x + y*y)
    theta = atan2(z*d.a, p*d.b)
    lambda = atan2(y, x)
    phi = atan2(z + d.e_prime^2 * d.b * sin(theta)^3, p - d.e*d.e*d.a*cos(theta)^3)

    N = d.a / sqrt(1 - d.e*d.e * sin(phi)^2)   # Radius of curvature (meters)
    h = p / cos(phi) - N

    return LLA(phi*180/pi, lambda*180/pi, h)
end

# For dictionary of nodes
function ecef2lla(nodes::Dict{Int,ECEF})
    nodesLLA = Dict{Int,LLA}()
    datum = WGS84()

    for key in keys(nodes)
        nodesLLA[key] = ecef2lla(nodes[key], datum)
    end

    return nodesLLA
end

###############################################
### Conversion from ECEF to ENU coordinates ###
###############################################

# Given a reference point for linarization
function ecef2enu(ecef::ECEF, lla_ref::LLA)
    # Reference point to linearize about
    phi = lla_ref.lat
    lambda = lla_ref.lon

    ecef_ref = lla2ecef(lla_ref)
    ecef_vec = [ecef.x - ecef_ref.x; ecef.y - ecef_ref.y; ecef.z - ecef_ref.z]

    # Compute rotation matrix
    R = [-sind(lambda) cosd(lambda) 0;
         -cosd(lambda)*sind(phi) -sind(lambda)*sind(phi) cosd(phi);
         cosd(lambda)*cosd(phi) sind(lambda)*cosd(phi) sind(phi)]
    ned = R * ecef_vec

    # Extract elements from vector
    east = ned[1]
    north = ned[2]
    up = ned[3]

    return ENU(east, north, up)
end

# Given Bounds object for linearization
function ecef2enu(ecef::ECEF, bounds::Bounds)
    lla_ref = centerBounds(bounds)

    return ecef2enu(ecef, lla_ref)
end

# For dictionary of nodes
function ecef2enu(nodes::Dict{Int,ECEF}, bounds::Bounds)
    nodesENU = Dict{Int,ENU}()
    lla_ref = centerBounds(bounds)

    for key in keys(nodes)
        nodesENU[key] = ecef2enu(nodes[key], lla_ref)
    end

    return nodesENU
end


##############################################
### Conversion from LLA to ENU coordinates ###
##############################################

# For single-point calculations, given bounds
function lla2enu(lla::LLA, bounds::Bounds)
    ecef = lla2ecef(lla)
    enu = ecef2enu(ecef, bounds)
    return enu
end

# For single-point calculations, given reference point
function lla2enu(lla::LLA, lla_ref::LLA)
    ecef = lla2ecef(lla)
    enu = ecef2enu(ecef, lla_ref)
    return enu
end

# For multi-point loops, given reference point in LLA
function lla2enu(lla::LLA, datum::WGS84, lla_ref::LLA)
    ecef = lla2ecef(lla, datum)
    enu = ecef2enu(ecef, lla_ref)
    return enu
end

# For dictionary of LLA nodes, given Bounds
function lla2enu(nodes::Dict{Int,LLA}, bounds::Bounds)
    lla_ref = centerBounds(bounds)

    return lla2enu(nodes, lla_ref)
end

# For dictionary of LLA nodes, given reference point
function lla2enu(nodes::Dict{Int,LLA}, lla_ref::LLA)
    nodesENU = Dict{Int,ENU}()
    datum = WGS84()

    for key in keys(nodes)
        nodesENU[key] = lla2enu(nodes[key], datum, lla_ref)
    end

    return nodesENU
end

# For Bounds objects without a reference point
function lla2enu(bounds::Bounds)
    top_left_LLA = LLA(bounds.max_lat, bounds.min_lon)
    bottom_right_LLA = LLA(bounds.min_lat, bounds.max_lon)

    top_left_ENU = lla2enu(top_left_LLA, bounds)
    bottom_right_ENU = lla2enu(bottom_right_LLA, bounds)

    bounds_ENU = Bounds(bottom_right_ENU.north, top_left_ENU.north, top_left_ENU.east, bottom_right_ENU.east)

    return bounds_ENU
end

# For Bounds objects given a reference point
function lla2enu(bounds::Bounds, lla_ref::LLA)
    top_left_LLA = LLA(bounds.max_lat, bounds.min_lon)
    bottom_right_LLA = LLA(bounds.min_lat, bounds.max_lon)

    top_left_ENU = lla2enu(top_left_LLA, lla_ref)
    bottom_right_ENU = lla2enu(bottom_right_LLA, lla_ref)

    bounds_ENU = Bounds(bottom_right_ENU.north, top_left_ENU.north, top_left_ENU.east, bottom_right_ENU.east)

    return bounds_ENU
end


########################
### Helper Functions ###
########################

### Get center point of Bounds region ###
function centerBounds(bounds::Bounds)
    lat_ref = (bounds.min_lat + bounds.max_lat) / 2
    lon_ref = (bounds.min_lon + bounds.max_lon) / 2

    return LLA(lat_ref, lon_ref)
end
