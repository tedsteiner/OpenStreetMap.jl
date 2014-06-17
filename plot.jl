### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for plotting using the Winston package ###

### Generic Map Plot ###
function plotMap( nodes::Dict{Int64,LatLon};
                  highways::Array{Highway,1}=nothing,
                  buildings::Array{Building,1}=nothing,
                  features::Array{Feature,1}=nothing,
                  bounds::Bounds=nothing,
                  intersections=nothing,
                  highway_style::String="b-",
                  building_style::String="k-",
                  feature_style::String="r.",
                  intersection_style::String="k.",
                  highway_lw::Real=1.5,
                  building_lw::Real=1,
                  feature_lw::Real=2.5,
                  intersection_lw::Real=3,
                  width::Integer=500,
                  realtime::Bool=false)

    # Compute plot height for approximate scaling
    height = width
    if bounds != nothing
        aspect_ratio = getAspectRatio( bounds )
        height = int( height / aspect_ratio )
    end

    # Create a figure
    fignum = Winston.figure(name="OpenStreetMap Plot", width=width, height=height)
    Winston.hold(true)

    # Limit plot to specified bounds
    if bounds != nothing
        Winston.xlim(bounds.min_lon,bounds.max_lon)
        Winston.ylim(bounds.min_lat,bounds.max_lat)
    end

    # Iterate over all highways and draw
    if highways != nothing
        for k = 1:length(highways)
            # Get coordinates of all nodes for object
            coords = getNodeCoords(nodes, highways[k].nodes)

            # Add line(s) to plot
            drawNodes(coords, highway_style, highway_lw, realtime)
        end
    end

    # Iterate over all buildings and draw
    if buildings != nothing
        for k = 1:length(buildings)
            # Get coordinates of all nodes for object
            coords = getNodeCoords(nodes, buildings[k].nodes)

            # Add line(s) to plot
            drawNodes(coords, building_style, building_lw, realtime)
        end
    end

    # Iterate over all features and draw
    if features != nothing
        coords = zeros(length(features),2)
        for k = 1:length(features)
            # Get coordinates of all nodes for object
            coords[k,:] = getNodeCoords(nodes, features[k].id)
        end
        # Add feature point(s) to plot
        drawNodes(coords, feature_style, feature_lw, realtime)
    end

    # Iterate over all intersections and draw
    if intersections != nothing
        intersection_nodes = zeros(length(intersections))
        coords = zeros(length(intersections),2)
        k = 1
        for key in keys(intersections)
            coords[k,:] = getNodeCoords(nodes, key)
            k += 1
        end

        # Add intersection(s) to plot
        drawNodes(coords, intersection_style, intersection_lw, realtime)
    end

    # Axes labels, etc.
    Winston.xlabel("Longitude")
    display(Winston.ylabel("Latitude"))
    Winston.hold(false)

    # Return figure number
    return fignum
end

### Get coordinates of lists of nodes ###
function getNodeCoords( nodes, id_list )
    coords = zeros(length(id_list),2)

    for k = 1:length(id_list)
        loc = nodes[id_list[k]]
        coords[k,1] = loc.lon
        coords[k,2] = loc.lat
    end

    return coords
end

### Draw a line between all points in a coordinate list ###
function drawNodes( coords, style="k-", width=1, realtime=false )
    x = coords[:,1]
    y = coords[:,2]
    if length(x) > 1
        if realtime
            display(Winston.plot(x,y,style,linewidth=width))
        else
            Winston.plot(x,y,style,linewidth=width)
        end
    end
    nothing
end

### Compute approximate "aspect ratio" at mean latitude ###
function getAspectRatio( bounds::Bounds )
    c_adj = cosd(mean([bounds.min_lat,bounds.max_lat]))
    range_lat = bounds.max_lat - bounds.min_lat
    range_lon = bounds.max_lon - bounds.min_lon

    return range_lon * c_adj / range_lat
end
