### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Crop map elements without copying data ###
function cropMap!( nodes::Dict,
                   bounds::Bounds;
                   highways=nothing,
                   buildings=nothing,
                   features=nothing,
                   delete_nodes::Bool=true )

    if typeof(nodes) != Dict{Int,LLA} && typeof(nodes) != Dict{Int,ENU}
        println("[OpenStreetMap.jl] ERROR: Input argument <nodes> in cropMap!() has unsupported type.")
        println("[OpenStreetMap.jl] Required type: Dict{Int64,LLA} OR Dict{Int64,ENU}")
        println("[OpenStreetMap.jl] Current type: $(typeof(nodes))")
        return
    end

    if highways != nothing
        if typeof(highways) == Array{Highway,1}
            crop!(nodes, bounds, highways)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <highways> in cropMap!() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Array{Highway,1}")
            println("[OpenStreetMap.jl] Current type: $(typeof(highways))")
        end
    end

    if buildings != nothing
        if typeof(buildings) == Array{Building,1}
            crop!(nodes, bounds, buildings)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <buildings> in cropMap!() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Array{Building,1}")
            println("[OpenStreetMap.jl] Current type: $(typeof(buildings))")
        end
    end

    if features != nothing
        if typeof(features) == Array{Feature,1}
            crop!(nodes, bounds, features)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <features> in cropMap!() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Array{Feature,1}")
            println("[OpenStreetMap.jl] Current type: $(typeof(features))")
        end
    end

    if delete_nodes
        crop!(nodes, bounds)
    end

    return nothing
end

### Crop nodes ###
function crop!(nodes::Dict, bounds::Bounds)
    for key in keys(nodes)
        if !inBounds(nodes[key],bounds)
            delete!(nodes,key)
        end
    end

    return nothing
end

### Crop highways ###
function crop!(nodes::Dict, bounds::Bounds, highways::Array{Highway,1})
    crop_list = falses(length(highways))

    for k = 1:length(highways)
        highway = highways[k]

        valid = falses(length(highway.nodes))
        for n = 1:length(highway.nodes)
            valid[n] = inBounds(nodes[highway.nodes[n]],bounds)
        end

        nodes_in_bounds = sum(valid)
        if nodes_in_bounds == 0
            # Remove highway from list
            crop_list[k] = true
        elseif nodes_in_bounds < length(valid)
            # Reduce highway by interpolating to bounds
            cropHighway!(nodes,bounds,highway,valid)
        end
    end

    cropList!(highways, crop_list)

    return nothing
end

### Crop buildings ###
function crop!(nodes::Dict, bounds::Bounds, buildings::Array{Building,1})
    crop_list = falses(length(buildings))

    for k = 1:length(buildings)
        building = buildings[k]

        valid = falses(length(building.nodes))
        for n = 1:length(building.nodes)
            valid[n] = inBounds(nodes[building.nodes[n]],bounds)
        end

        nodes_in_bounds = sum(valid)
        if nodes_in_bounds == 0
            crop_list[k] = true
        elseif nodes_in_bounds < length(valid)
            # TODO: Interpolate buildings to bounds?
            crop_list[k] = true
        end
    end

    cropList!(buildings, crop_list)

    return nothing
end

### Crop features ###
function crop!(nodes::Dict, bounds::Bounds, features::Array{Feature,1})
    crop_list = falses(length(features))

    for k = 1:length(features)
        crop_list[k] = !inBounds(nodes[features[k].id], bounds)
    end

    cropList!(features, crop_list)

    return nothing
end

### Check whether a location is within bounds ###
function inBounds(loc::LLA, bounds::Bounds)
    lat = loc.lat
    lon = loc.lon

    if lat < bounds.min_lat || lat > bounds.max_lat
        return false
    elseif lon < bounds.min_lon || lon > bounds.max_lon
        return false
    end

    return true
end

function inBounds(loc::ENU, bounds::Bounds)
    north = loc.north
    east = loc.east

    if north < bounds.min_lat || north > bounds.max_lat
        return false
    elseif east < bounds.min_lon || east > bounds.max_lon
        return false
    end

    return true
end

### Remove specified items from an array ###
function cropList!(list::Array, crop_list::BitArray{1})
    kk = length(list)
    for k = 1:length(list)
        if crop_list[kk]
            splice!(list,kk)
        end
        kk -= 1
    end

    return nothing
end

### Crop highway to fit within bounds, interpolating to place ###
### new nodes on the boundary as necessary.                   ###
function cropHighway!(nodes::Dict, bounds::Bounds, highway::Highway, valid::BitArray{1})
    inside = find(valid)
    first_inside = inside[1]
    last_inside = inside[end]

    # Remove bad nodes at end of highway node list
    if last_inside+1 < length(highway.nodes)
        for k = (last_inside+2):length(highway.nodes)
            pop!(highway.nodes)
            pop!(valid)
        end
    end

    # Remove bad nodes at start of highway node list
    if first_inside > 2
        ind = first_inside - 2
        for k = 1:(first_inside-2)
            splice!(highway.nodes,ind)
            splice!(valid,ind)
            ind -= 1
        end
    end

    interpolate_start = !valid[1]
    interpolate_end = !valid[end]

    if interpolate_end
        last_inside = find(valid)[end]
        const node0 = highway.nodes[last_inside]
        const x0 = getX( nodes[node0] )
        const y0 = getY( nodes[node0] )
        node1 = highway.nodes[last_inside+1]
        x1 = getX( nodes[node1] )
        y1 = getY( nodes[node1] )

        if x1 < bounds.min_lon || x1 > bounds.max_lon
            if x1 < bounds.min_lon
                x = bounds.min_lon
            else
                x = bounds.max_lon
            end
            y = y0 + (y1 - y0) * (x - x0) / (x1 - x0)

            # Add a new node to nodes list
            if typeof(nodes[node0]) == LLA
                new_id = addNewNode(nodes,LLA(y,x))
            else # ENU
                new_id = addNewNode(nodes,ENU(x,y))
            end
            highway.nodes[last_inside+1] = new_id
            valid[last_inside+1] = inBounds(nodes[new_id],bounds)
        end

        if !valid[last_inside+1]
            node1 = highway.nodes[last_inside+1]
            x1 = getX( nodes[node1] )
            y1 = getY( nodes[node1] )

            if y1 < bounds.min_lat || y1 > bounds.max_lat
                if y1 < bounds.min_lat
                    y = bounds.min_lat
                else
                    y = bounds.max_lat
                end
                x = x0 + (x1-x0) * (y - y0) / (y1 - y0)

                # Add a new node to nodes list
                if typeof(nodes[node0]) == LLA
                    new_id = addNewNode(nodes,LLA(y,x))
                else # ENU
                    new_id = addNewNode(nodes,ENU(x,y))
                end
                highway.nodes[last_inside+1] = new_id
                valid[last_inside+1] = inBounds(nodes[new_id],bounds)
            end
        end
    end

    if interpolate_start
        first_inside = find(valid)[1]
        const node0 = highway.nodes[first_inside]
        const x0 = getX( nodes[node0] )
        const y0 = getY( nodes[node0] )
        node1 = highway.nodes[first_inside-1]
        x1 = getX( nodes[node1] )
        y1 = getY( nodes[node1] )

        if x1 < bounds.min_lon || x1 > bounds.max_lon
            if x1 < bounds.min_lon
                x = bounds.min_lon
            else
                x = bounds.max_lon
            end
            y = y0 + (y1 - y0) * (x - x0) / (x1 - x0);

            # Add a new node to nodes list
            if typeof(nodes[node0]) == LLA
                new_id = addNewNode(nodes,LLA(y,x))
            else # ENU
                new_id = addNewNode(nodes,ENU(x,y))
            end
            highway.nodes[first_inside-1] = new_id
            valid[first_inside-1] = inBounds(nodes[new_id],bounds)
        end

        if !valid[first_inside-1]
            node1 = highway.nodes[first_inside-1]
            x1 = getX( nodes[node1] )
            y1 = getY( nodes[node1] )

            if y1 < bounds.min_lat || y1 > bounds.max_lat
                if y1 < bounds.min_lat
                    y = bounds.min_lat
                else
                    y = bounds.max_lat
                end
                x = x0 + (x1-x0) * (y - y0) / (y1 - y0)

                # Add a new node to nodes list
                if typeof(nodes[node0]) == LLA
                    new_id = addNewNode(nodes,LLA(y,x))
                else # ENU
                    new_id = addNewNode(nodes,ENU(x,y))
                end
                highway.nodes[first_inside-1] = new_id
                valid[first_inside-1] = inBounds(nodes[new_id],bounds)
            end
        end
    end

    return nothing
end

### Add a new node ###
function addNewNode(nodes::Dict{Int,LLA}, loc::LLA)
    return addNewNodeInternal(nodes, loc)
end

function addNewNode(nodes::Dict{Int,ENU}, loc::ENU)
    return addNewNodeInternal(nodes, loc)
end

function addNewNodeInternal(nodes, loc)
    id = 1
    while id <= typemax(Int)
        if !haskey(nodes,id)
            nodes[id] = loc
            return id
        else
            id += 1
        end
    end

    println("[OpenStreetMap.jl] WARNING: Unable to add a new node to map, $(typemax(Int)) nodes is currently the maximum.")
    return 0
end
