### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for plotting using the Winston package ###

### Generic Map Plot ###
function plotMap(nodes;
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
                 highway_style::Style=Style(0x007CFF, 1.5, "-"),
                 building_style::Style=Style(0x000000, 1, "-"),
                 feature_style=Style(0xCC0000, 2.5, "."),
                 route_style=Style(0xFF0000, 3, "-"),
                 intersection_style::Style=Style(0x000000, 3, "."),
                 width::Integer=500,
                 fontsize::Integer=0,
                 km::Bool=false,
                 realtime::Bool=false)

    # Check if bounds type is correct
    if bounds != nothing
        if !isa(bounds, Bounds)
            println("[OpenStreetMap.jl] Warning: Input argument <bounds> in plotMap() unused due to incorrect type.")
            println("[OpenStreetMap.jl] Required type: Bounds")
            println("[OpenStreetMap.jl] Current type: $(typeof(bounds))")
            bounds = nothing
        end
    end

    # Check input node type and compute plot height accordingly
    height = width
    if isa(nodes, Dict{Int,LLA})
        xlab = "Longitude (deg)"
        ylab = "Latitude (deg)"

        if bounds != nothing
            aspect_ratio = aspectRatio(bounds)
            height = int(height / aspect_ratio)
        end
    elseif isa(nodes, Dict{Int,ENU})
        if km
            xlab = "East (km)"
            ylab = "North (km)"
        else
            xlab = "East (m)"
            ylab = "North (m)"
        end

        # Waiting for Winston to add capability to force equal scales. For now:
        if bounds != nothing
            xrange = bounds.max_x - bounds.min_x
            yrange = bounds.max_y - bounds.min_y
            aspect_ratio = xrange / yrange
            height = int(width / aspect_ratio)
        end
    else
        println("[OpenStreetMap.jl] ERROR: Input argument <nodes> in plotMap() has unsupported type.")
        println("[OpenStreetMap.jl] Required type: Dict{Int,LLA} OR Dict{Int,ENU}")
        println("[OpenStreetMap.jl] Current type: $(typeof(nodes))")
        return
    end

    # Create the figure
    fignum = Winston.figure(name="OpenStreetMap Plot", width=width, height=height)
    p = Winston.FramedPlot("xlabel", xlab, "ylabel", ylab)

    # Limit plot to specified bounds
    if bounds != nothing
        Winston.xlim(bounds.min_x, bounds.max_x)
        Winston.ylim(bounds.min_y, bounds.max_y)

        if km && isa(nodes, Dict{Int,ENU})
            xrange = (bounds.min_x/1000, bounds.max_x/1000)
            yrange = (bounds.min_y/1000, bounds.max_y/1000)
        else
            xrange = (bounds.min_x, bounds.max_x)
            yrange = (bounds.min_y, bounds.max_y)
        end

        p = Winston.FramedPlot("xlabel", xlab, "ylabel", ylab, xrange=xrange, yrange=yrange)
    end

    # Iterate over all buildings and draw
    if buildings != nothing
        if isa(buildings, Dict{Int,Building})
            if building_classes != nothing && isa(building_classes, Dict{Int,Int})
                if isa(building_style, Dict{Int,Style})
                    drawWayLayer(p, nodes, buildings, building_classes, building_style, km, realtime)
                else
                    drawWayLayer(p, nodes, buildings, building_classes, LAYER_BUILDINGS, km, realtime)
                end
            else
                for (key, building) in buildings
                    # Get coordinates of all nodes for object
                    coords = getNodeCoords(nodes, building.nodes, km)

                    # Add line(s) to plot
                    drawNodes(p, coords, building_style, realtime)
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
        if isa(highways, Dict{Int,Highway})
            if roadways != nothing || cycleways != nothing || walkways != nothing
                if roadways != nothing
                    if isa(highway_style, Dict{Int,Style})
                        drawWayLayer(p, nodes, highways, roadways, highway_style, km, realtime)
                    else
                        drawWayLayer(p, nodes, highways, roadways, LAYER_STANDARD, km, realtime)
                    end
                end
                if cycleways != nothing
                    if isa(highway_style, Dict{Int,Style})
                        drawWayLayer(p, nodes, highways, cycleways, highway_style, km, realtime)
                    else
                        drawWayLayer(p, nodes, highways, cycleways, LAYER_CYCLE, km, realtime)
                    end
                end
                if walkways != nothing
                    if isa(highway_style, Dict{Int,Style})
                        drawWayLayer(p, nodes, highways, walkways, highway_style, km, realtime)
                    else
                        drawWayLayer(p, nodes, highways, walkways, LAYER_PED, km, realtime)
                    end
                end
            else
                for (key, highway) in highways
                    # Get coordinates of all nodes for object
                    coords = getNodeCoords(nodes, highway.nodes, km)

                    # Add line(s) to plot
                    drawNodes(p, coords, highway_style, realtime)
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
        if isa(features, Dict{Int,Feature})
            if feature_classes != nothing && isa(feature_classes, Dict{Int,Int})
                if isa(feature_style, Style)
                    drawFeatureLayer(p, nodes, features, feature_classes, LAYER_FEATURES, km, realtime)
                elseif isa(feature_style, Dict{Int,Style})
                    drawFeatureLayer(p, nodes, features, feature_classes, feature_style, km, realtime)
                end
            else
                coords = getNodeCoords(nodes, collect(keys(features)), km)

                # Add feature point(s) to plot
                drawNodes(p, coords, feature_style, realtime)
            end
        else
            println("[OpenStreetMap.jl] Warning: Input argument <features> in plotMap() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Feature}")
            println("[OpenStreetMap.jl] Current type: $(typeof(features))")
        end
    end

    # Draw route
    if route != nothing
        if isa(route, Vector{Int})
            # Get coordinates of all nodes for route
            coords = getNodeCoords(nodes, route, km)

            # Add line(s) to plot
            drawNodes(p, coords, route_style, realtime)
        elseif isa(route, Vector{Vector{Int}})
            for k = 1:length(route)
                coords = getNodeCoords(nodes, route[k], km)
                if isa(route_style, Vector{Style})
                    drawNodes(p, coords, route_style[k], realtime)
                elseif isa(route_style, Style)
                    drawNodes(p, coords, route_style, realtime)
                else
                    println("[OpenStreetMap.jl] Warning: Route in plotMap() could not be plotted.")
                    println("[OpenStreetMap.jl] Required <route_style> type: Style or Vector{Style}")
                    println("[OpenStreetMap.jl] Current type: $(typeof(route_style))")
                end
            end
        else
            println("[OpenStreetMap.jl] Warning: Input argument <route> in plotMap() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Vector{Int64}")
            println("[OpenStreetMap.jl] Current type: $(typeof(route))")
        end
    end

    # Iterate over all intersections and draw
    if intersections != nothing
        if isa(intersections, Dict{Int,Intersection})
            coords = Array(Float64, length(intersections), 2)
            k = 1
            for key in keys(intersections)
                coords[k, :] = getNodeCoords(nodes, key, km)
                k += 1
            end

            # Add intersection(s) to plot
            drawNodes(p, coords, intersection_style, realtime)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <intersections> in plotMap() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Intersection}")
            println("[OpenStreetMap.jl] Current type: $(typeof(intersections))")
        end
    end

    if fontsize > 0
        Winston.setattr(p.x1, "label_style", [:fontsize=>fontsize])
        Winston.setattr(p.y1, "label_style", [:fontsize=>fontsize])
        Winston.setattr(p.x1, "ticklabels_style", [:fontsize=>fontsize])
        Winston.setattr(p.y1, "ticklabels_style", [:fontsize=>fontsize])
    end

    display(p)

    # Return figure object (enables further manipulation)
    return p
end

### Draw layered Map ###
function drawWayLayer(p::Winston.FramedPlot, nodes::Dict, ways, classes, layer, km=false, realtime=false)
    for (key, class) in classes
        # Get coordinates of all nodes for object
        coords = getNodeCoords(nodes, ways[key].nodes, km)

        # Add line(s) to plot
        drawNodes(p, coords, layer[class], realtime)
    end
end

### Draw layered features ###
function drawFeatureLayer(p::Winston.FramedPlot, nodes::Dict, features, classes, layer, km=false, realtime=false)

    for id in unique(values(classes))
        ids = Int[]

        for (key, class) in classes
            if class == id
                push!(ids, key)
            end
        end

        # Get coordinates of node for object
        coords = getNodeCoords(nodes, ids, km)

        # Add point to plot
        drawNodes(p, coords, layer[id], realtime)
    end
end

### Get coordinates of lists of nodes ###
# Nodes in LLA coordinates
function getNodeCoords(nodes::Dict{Int,LLA}, id_list, km=false)
    coords = Array(Float64, length(id_list), 2)

    for k = 1:length(id_list)
        loc = nodes[id_list[k]]
        coords[k, 1] = loc.lon
        coords[k, 2] = loc.lat
    end

    return coords
end

# Nodes in ENU coordinates
function getNodeCoords(nodes::Dict{Int,ENU}, id_list, km=false)
    coords = Array(Float64, length(id_list), 2)

    for k = 1:length(id_list)
        loc = nodes[id_list[k]]
        coords[k, 1] = loc.east
        coords[k, 2] = loc.north
    end

    if km
        coords /= 1000
    end

    return coords
end

### Draw a line between all points in a coordinate list ###
function drawNodes(p::Winston.FramedPlot, coords, style="k-", width=1, realtime=false)
    x = coords[:, 1]
    y = coords[:, 2]
    if length(x) > 1
        if realtime
            display(Winston.plot(p, x, y, style, linewidth=width))
        else
            Winston.plot(p, x, y, style, linewidth=width)
        end
    end
    nothing
end

### Draw a line between all points in a coordinate list given Style object ###
function drawNodes(p::Winston.FramedPlot, coords, line_style::Style, realtime=false)
    x = coords[:, 1]
    y = coords[:, 2]
    if length(x) > 1
        if realtime
            display(Winston.plot(p, x, y, line_style.spec, color=line_style.color, linewidth=line_style.width))
        else
            Winston.plot(p, x, y, line_style.spec, color=line_style.color, linewidth=line_style.width)
        end
    end
    nothing
end

### Compute approximate "aspect ratio" at mean latitude ###
function aspectRatio(bounds::Bounds{LLA})
    c_adj = cosd((bounds.min_y + bounds.max_y) / 2)
    range_y = bounds.max_y - bounds.min_y
    range_x = bounds.max_x - bounds.min_x

    return range_x * c_adj / range_y
end

### Compute excact "aspect ratio" ###
function aspectRatio(bounds::Bounds{ENU})
    range_y = bounds.max_y - bounds.min_y
    range_x = bounds.max_x - bounds.min_x

    return range_x / range_y
end
