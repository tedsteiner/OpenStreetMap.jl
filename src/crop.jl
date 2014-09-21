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
        println("[OpenStreetMap.jl] Required type: Dict{Int,LLA} OR Dict{Int,ENU}")
        println("[OpenStreetMap.jl] Current type: $(typeof(nodes))")
        return
    end

    if highways != nothing
        if typeof(highways) == Dict{Int,Highway}
            crop!(nodes, bounds, highways)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <highways> in cropMap!() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Highway}")
            println("[OpenStreetMap.jl] Current type: $(typeof(highways))")
        end
    end

    if buildings != nothing
        if typeof(buildings) == Dict{Int,Building}
            crop!(nodes, bounds, buildings)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <buildings> in cropMap!() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Building}")
            println("[OpenStreetMap.jl] Current type: $(typeof(buildings))")
        end
    end

    if features != nothing
        if typeof(features) == Dict{Int,Feature}
            crop!(nodes, bounds, features)
        else
            println("[OpenStreetMap.jl] Warning: Input argument <features> in cropMap!() could not be plotted.")
            println("[OpenStreetMap.jl] Required type: Dict{Int,Feature}")
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
function crop!(nodes::Dict, bounds::Bounds, highways::Dict{Int,Highway})
    missing_nodes = Int[]

    for (key, highway) in highways
        valid = falses(length(highway.nodes))
        #println(highway.nodes)
        #for n = 1:length(highway.nodes)
        n = 1
        while n <= length(highway.nodes)
            #println("Length: $(length(highway.nodes)), n = $(n)")
            if haskey(nodes, highway.nodes[n])
                valid[n] = inBounds(nodes[highway.nodes[n]],bounds)
                n += 1
            else
                #println(highway.nodes)
                push!(missing_nodes,highway.nodes[n])
                splice!(highway.nodes,n)
                splice!(valid,n)
                #println(highway.nodes)
                #println("n = $(n)")
            end
        end

        nodes_in_bounds = sum(valid)

        if nodes_in_bounds == 0
            delete!(highways,key)   # Remove highway from list
        elseif nodes_in_bounds < length(valid)
            cropHighway!(nodes,bounds,highway,valid) # Crop highway length
        end
    end

    if length(missing_nodes) > 0
        println("[OpenStreetMap.jl] WARNING: $(length(missing_nodes)) missing nodes were removed from highways.")
    end

    return missing_nodes
end

### Crop buildings ###
function crop!(nodes::Dict, bounds::Bounds, buildings::Dict{Int,Building})
    for key in keys(buildings)
        valid = falses(length(buildings[key].nodes))
        for n = 1:length(buildings[key].nodes)
            if haskey(nodes, buildings[key].nodes[n])
                valid[n] = inBounds(nodes[buildings[key].nodes[n]],bounds)
            end
        end

        nodes_in_bounds = sum(valid)
        if nodes_in_bounds == 0
            delete!(buildings,key)   # Remove building from list
        elseif nodes_in_bounds < length(valid)
            # TODO: Interpolate buildings to bounds?
            delete!(buildings,key)   # Remove building from list
        end
    end

    return nothing
end

### Crop features ###
function crop!(nodes::Dict, bounds::Bounds, features::Dict{Int,Feature})
    for key in keys(features)
        if !haskey(nodes, key) || !inBounds(nodes[key], bounds)
            delete!(features,key)
        end
    end

    return nothing
end

### Check whether a location is within bounds ###
function inBounds(loc::LLA, bounds::Bounds)
    lat = loc.lat
    lon = loc.lon

    bounds.min_lat <= lat <= bounds.max_lat &&
    bounds.min_lon <= lon <= bounds.max_lon
end

function inBounds(loc::ENU, bounds::Bounds)
    north = loc.north
    east = loc.east

    bounds.min_lat <= north <= bounds.max_lat &&
    bounds.min_lon <= east <= bounds.max_lon
end

function onBounds(loc::LLA, bounds::Bounds)
    lat = loc.lat
    lon = loc.lon

    lat == bounds.min_lat || lat == bounds.max_lat ||
    lon == bounds.min_lon || lon == bounds.max_lon
end

function onBounds(loc::ENU, bounds::Bounds)
    north = loc.north
    east = loc.east

    north == bounds.min_lat || north == bounds.max_lat ||
    east == bounds.min_lon || east == bounds.max_lon
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

function boundaryPoint{T}(p1::T, p2::T, bounds::Bounds)
    x1, y1 = getX(p1), getY(p1)
    x2, y2 = getX(p2), getY(p2)

    x, y = x1, y1

    # checks assume inBounds(p1) != inBounds(p2)
    if x1 < bounds.min_lon < x2 || x1 > bounds.min_lon > x2
        x = bounds.min_lon
        y = y1 + (y2 - y1) * (bounds.min_lon - x1) / (x2 - x1)
    elseif x1 < bounds.max_lon < x2 || x1 > bounds.max_lon > x2
        x = bounds.max_lon
        y = y1 + (y2 - y1) * (bounds.max_lon - x1) / (x2 - x1)
    end

    p3 = T == LLA ? T(y, x) : T(x, y)
    inBounds(p3, bounds) && return p3

    if y1 < bounds.min_lat < y2 || y1 > bounds.min_lat > y2
        x = x1 + (x2 - x1) * (bounds.min_lat - y1) / (y2 - y1)
        y = bounds.min_lat
    elseif y1 < bounds.max_lat < y2 || y1 > bounds.max_lat > y2
        x = x1 + (x2 - x1) * (bounds.max_lat - y1) / (y2 - y1)
        y = bounds.max_lat
    end

    p3 = T == LLA ? T(y, x) : T(x, y)
    inBounds(p3, bounds) && return p3

    error("Failed to find boundary point.")
end

function cropHighway!(nodes::Dict, bounds::Bounds, highway::Highway, valids::BitArray{1})
    prev_id, prev_valid = highway.nodes[1], valids[1]
    ni = 1
    for i in 1:length(valids)
        id, valid = highway.nodes[ni], valids[i]

        if !valid
            deleteat!(highway.nodes, ni)
            ni -= 1
        end
        if valid != prev_valid
            prev_node, node = nodes[prev_id], nodes[id]
            if !(onBounds(prev_node, bounds) || onBounds(node, bounds))
                new_node = boundaryPoint(prev_node, node, bounds)
                new_id = addNewNode(nodes, new_node)
                insert!(highway.nodes, ni + !valid, new_id)
                ni += 1
            end
        end

        ni += 1

        prev_id, prev_valid = id, valid
    end

    return nothing
end
