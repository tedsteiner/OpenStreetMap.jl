### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for map coordinate transformations ###

### Conversion from Lat-Lon-Alt to Earth-Centered-Earth-Fixed coordinates ###
function lla2ecef( lla::LatLon )
    # Latitude and Longitude
    lat = lla.lat
    lon = lla.lon
    alt = lla.alt

    d = WSG84() # Get WSG84 datum

    N = d.a / sqrt(1 - d.e*d.e * sind(lat)^2)   # Radius of curvature (meters)

    x = (N + alt) * cosd(lat) * cosd(lon)
    y = (N + alt) * cosd(lat) * sind(lon)
    z = (N * (1 - d.e*d.e) + alt) * sind(lat)

    return ECEF(x,y,z)
end

### Conversion from Earth-Centered-Earth-Fixed to Lat-Lon-Alt coordinates ###
function ecef2lla( ecef::ECEF )
    x = ecef.x
    y = ecef.y
    z = ecef.z

    d = WSG84() # Get WSG84 datum

    p = sqrt( x*x + y*y )
    theta = atan2( z*d.a, p*d.b )
    lambda = atan2(y,x)
    phi = atan2(z + d.e_prime^2 * d.b * sin(theta)^3, p - d.e*d.e*d.a*cos(theta)^3)

    N = d.a / sqrt(1 - d.e*d.e * sin(phi)^2)   # Radius of curvature (meters)
    h = p / cos(phi) - N

    return LatLon(phi*180/pi, lambda*180/pi, h)
end

### Convert ECEF point to LLA ###
function ecef2enu( ecef::ECEF, lla_ref::LatLon )
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
    e = ned[1]
    n = ned[2]
    u = ned[3]

    return ENU(e,n,u)
end

### Convert ECEF point to ENU given Bounds ###
function ecef2enu( ecef::ECEF, bounds::Bounds )
    lat_ref = ( bounds.min_lat + bounds.max_lat ) / 2
    lon_ref = ( bounds.min_lon + bounds.max_lon ) / 2

    return ecef2enu( ecef, LatLon(lat_ref,lon_ref) )
end

### Convert LLA point to ENU given Bounds ###
function lla2enu( lla::LatLon , bounds::Bounds )
    ecef = lla2ecef( lla )
    enu = ecef2enu( ecef, bounds )
    return enu
end

### Convert dictionary of LLA points to ENU given Bounds ###
function lla2enu( nodes::Dict{Int,LatLon}, bounds::Bounds )
    nodesENU = Dict{Int,ENU}()

    for key in keys(nodes)
        nodesENU[key] = lla2enu( nodes[key], bounds )
    end

    return nodesENU
end

### Convert Bounds type from LLA to ENU ###
function lla2enu( bounds::Bounds )
    top_left_LLA = LatLon( bounds.max_lat, bounds.min_lon )
    bottom_right_LLA = LatLon( bounds.min_lat, bounds.max_lon )

    top_left_ENU = lla2enu( top_left_LLA, bounds )
    bottom_right_ENU = lla2enu( bottom_right_LLA, bounds )

    bounds_ENU = Bounds(top_left_ENU.east, bottom_right_ENU.east, bottom_right_ENU.north, top_left_ENU.north)

    return bounds_ENU
end
