### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for plotting using the Winston package ###

### Generic Map Plot ###
function plotMap( nodes;
                  highways=nothing,
                  buildings=nothing,
                  features=nothing,
                  bounds=nothing,
                  intersections=nothing,
                  roadways=nothing,
                  cycleways=nothing,
                  walkways=nothing,
                  feature_classes=nothing,
                  building_classes=nothing,
                  route=nothing,
                  route_style=nothing,
                  highway_style::String="b-",
                  building_style::String="k-",
                  feature_style::String="r.",
                  intersection_style::String="k.",
                  highway_lw::Real=1.5,
                  building_lw::Real=1,
                  feature_lw::Real=2.5,
                  intersection_lw::Real=3,
                  width::Integer=500,
                  realtime::Bool=false )

    # Check if bounds type is correct
    if bounds != nothing
        if typeof(bounds) != Bounds
            println("[OpenStreetMap.jl] Warning: Input argument <bounds> in plotMap() unused due to incorrect type.")
            println("[OpenStreetMap.jl] Required type: Bounds")
            println("[OpenStreetMap.jl] Current type: $(typeof(bounds))")
            bounds = nothing
        end
    end

    # Check input node type and compute plot height accordingly
    height = width
    if typeof(nodes) == Dict{Int,LLA}
        xlab = "Longitude (deg)"
        ylab = "Latitude (deg)"

        if bounds != nothing
            aspect_ratio = getAspectRatio( bounds )
            height = int( height / aspect_ratio )
        end
    elseif typeof(nodes) == Dict{Int,ENU}
        xlab = "East (m)"
        ylab = "North (m)"

        # Waiting for Winston to add capability to force equal scales. For now:
        if bounds != nothing
            xrange = bounds.max_lon - bounds.min_lon
            yrange = bounds.max_lat - bounds.min_lat
            aspect_ratio = xrange / yrange
            height = int( width / aspect_ratio )
        end
    else
        println("[OpenStreetMap.jl] ERROR: Input argument <nodes> in plotMap() has unsupported type.")
        println("[OpenStreetMap.jl] Required type: Dict{Int,LLA} OR Dict{Int,ENU}")
        println("[OpenStreetMap.jl] Current type: $(typeof(nodes))")
        return
    end

    # Create the figure
    fignum = Winston.figure(name="OpenStreetMap Plot", width=width, height=height)
    Winston.hold(true)

    # Limit plot to specified bounds
    if bounds != nothing
        Winston.xlim(bounds.min_lon,bounds.max_lon)
        Winston.ylim(bounds.min_lat,bounds.max_lat)
    end

    # Iterate over all buildings and draw
    if buildings != nothing
        if typeof(buildings) == Dict{Int,Building}
            if building_classes != nothing && typeof(building_classes) == Dict{Int,Int}
                drawWayLayer( nodes, buildings, building_classes, LAYER_BUILDINGS, realtime )
            else
                for key in keys(buildings)
                    # Get coordinates of all nodes for object
                    coords = getNodeCoords(nodes, buildings[key].nodes)

                    # Add line(s) to plot
                    drawNodes(coords, building_style, building_lw, realtime)
                end
            end
        else
            println("[OpenStreetMap.jl] Warning: Input argument <buildings> in plotMap() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Building}")
            println("[OpenStreetMap.jl] Current type: $(typeof(buildings))")
        end
    end

    # Iterate over all highways and draw
    if highways != nothing
        if typeof(highways) == Dict{Int,Highway}
            if roadways != nothing || cycleways != nothing || walkways != nothing
                if roadways != nothing
                    drawWayLayer( nodes, highways, roadways, LAYER_STANDARD, realtime )
                end
                if cycleways != nothing
                    drawWayLayer( nodes, highways, cycleways, LAYER_CYCLE, realtime )
                end
                if walkways != nothing
                    drawWayLayer( nodes, highways, walkways, LAYER_PED, realtime )
                end
            else
                for key in keys(highways)
                    # Get coordinates of all nodes for object
                    coords = getNodeCoords(nodes, highways[key].nodes)

                    # Add line(s) to plot
                    drawNodes(coords, highway_style, highway_lw, realtime)
                end
            end
        else
            println("[OpenStreetMap.jl] Warning: Input argument <highways> in plotMap() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Highway}")
            println("[OpenStreetMap.jl] Current type: $(typeof(highways))")
        end
    end

    # Iterate over all features and draw
    if features != nothing
        if typeof(features) == Dict{Int,Feature}
            if feature_classes != nothing && typeof(feature_classes) == Dict{Int,Int}
                drawFeatureLayer(nodes, features, feature_classes, LAYER_FEATURES, realtime)
            else
                coords = getNodeCoords(nodes, collect(keys(features)))

                # Add feature point(s) to plot
                drawNodes(coords, feature_style, feature_lw, realtime)
            end
        else
            println("[OpenStreetMap.jl] Warning: Input argument <features> in plotMap() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Feature}")
            println("[OpenStreetMap.jl] Current type: $(typeof(features))")
        end
    end

    # Draw route
    if route != nothing
        if typeof(route) == Array{Int64,1}
            # Get coordinates of all nodes for route
            coords = getNodeCoords(nodes, route)

            if route_style == nothing
                route_style = style(0xFF0000, 3, "-")
            else
                if typeof(route_style) == style

                else
                    println("[OpenStreetMap.jl] Warning: Input argument <route_style> in plotMap() unused.")
                    println("[OpenStreetMap.jl] Required type: style")
                    println("[OpenStreetMap.jl] Current type: $(typeof(route_style))")
                end
            end

            # Add line(s) to plot
            drawNodes(coords, route_style, realtime)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <route> in plotMap() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Array{Int64,1}")
            println("[OpenStreetMap.jl] Current type: $(typeof(route))")
        end
    end

    # Iterate over all intersections and draw
    if intersections != nothing
        if typeof(intersections) == Dict{Int,Intersection}
            intersection_nodes = zeros(length(intersections))
            coords = zeros(length(intersections),2)
            k = 1
            for key in keys(intersections)
                coords[k,:] = getNodeCoords(nodes, key)
                k += 1
            end

            # Add intersection(s) to plot
            drawNodes(coords, intersection_style, intersection_lw, realtime)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <intersections> in plotMap() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Intersection}")
            println("[OpenStreetMap.jl] Current type: $(typeof(intersections))")
        end
    end

    # Axes labels, etc.
    Winston.xlabel(xlab)
    display(Winston.ylabel(ylab))
    Winston.hold(false)

    # Return figure number
    return fignum
end


### Draw layered Map ###
function drawWayLayer( nodes::Dict, ways, classes, layer, realtime=false )
    for key in keys(classes)
        # Get coordinates of all nodes for object
        coords = getNodeCoords(nodes, ways[key].nodes)

        # Add line(s) to plot
        drawNodes(coords, layer[classes[key]], realtime)
    end
end


### Draw layered features ###
function drawFeatureLayer( nodes::Dict, features, classes, layer, realtime=false )
    class_ids = Set(collect(values(classes))...)

    for id in class_ids
        ids = Int[]

        for key in keys(classes)
            if classes[key] == id
                push!(ids,key)
            end
        end

        # Get coordinates of node for object
        coords = getNodeCoords(nodes, ids)

        # Add point to plot
        drawNodes(coords, layer[id], realtime)
    end
end


### Get coordinates of lists of nodes ###
# Nodes in LLA coordinates
function getNodeCoords( nodes::Dict{Int,LLA}, id_list )
    coords = zeros(length(id_list),2)

    for k = 1:length(id_list)
        loc = nodes[id_list[k]]
        coords[k,1] = loc.lon
        coords[k,2] = loc.lat
    end

    return coords
end


# Nodes in ENU coordinates
function getNodeCoords( nodes::Dict{Int,ENU}, id_list )
    coords = zeros(length(id_list),2)

    for k = 1:length(id_list)
        loc = nodes[id_list[k]]
        coords[k,1] = loc.east
        coords[k,2] = loc.north
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


### Draw a line between all points in a coordinate list given style object ###
function drawNodes( coords, line_style::style, realtime=false )
    x = coords[:,1]
    y = coords[:,2]
    if length(x) > 1
        if realtime
            display(Winston.plot(x,y,line_style.spec,color=line_style.color,linewidth=line_style.width))
        else
            Winston.plot(x,y,line_style.spec,color=line_style.color,linewidth=line_style.width)
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
