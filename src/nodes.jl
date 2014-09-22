### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Get dictionary of all nodes from an OSM XML file ###
function getNodes(street_map::LightXML.XMLDocument)

    xroot = LightXML.root(street_map)
    all_nodes = LightXML.get_elements_by_tagname(xroot, "node")
    nodes = Dict{Int,LLA}()

    for node in all_nodes

        if LightXML.has_attribute(node, "visible")
            if LightXML.attribute(node, "visible") == "false"
                # Visible=false indicates historic data, which we will ignore
                continue
            end
        end

        id = int(LightXML.attribute(node, "id"))
        lat = float(LightXML.attribute(node, "lat"))
        lon = float(LightXML.attribute(node, "lon"))

        nodes[id] = LLA(lat, lon)
    end

    return nodes
end


### Find the nearest node to a given location ###
function nearestNode(nodes::Dict{Int,ENU}, loc::ENU, node_list=0)
    return nearestNodeInternal(nodes, loc, node_list)
end

function nearestNode(nodes::Dict{Int,ECEF}, loc::ECEF, node_list=0)
    return nearestNodeInternal(nodes, loc, node_list)
end

function nearestNodeInternal(nodes, loc, node_list=0)
    min_dist = 1e8
    best_ind = 0

    if node_list != 0
        # Search only nodes in node_list
        for ind in node_list
            dist = distance(nodes[ind], loc)
            if dist < min_dist
                min_dist = dist
                best_ind = ind
            end
        end
    else
        # Search all nodes
        for (key, node) in nodes
            dist = distance(node, loc)
            if dist < min_dist
                min_dist = dist
                best_ind = key
            end
        end
    end

    return best_ind
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
        if !haskey(nodes, id)
            nodes[id] = loc
            return id
        else
            id += 1
        end
    end

    println("[OpenStreetMap.jl] WARNING: Unable to add a new node to map, $(typemax(Int)) nodes is currently the maximum.")
    return 0
end
