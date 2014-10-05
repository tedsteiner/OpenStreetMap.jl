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
function nearestNode{T<:Union(ENU,ECEF)}(nodes::Dict{Int,T}, loc::T)
    min_dist = Inf
    best_ind = 0

    for (key, node) in nodes
        dist = distance(node, loc)
        if dist < min_dist
            min_dist = dist
            best_ind = key
        end
    end

    return best_ind
end

function nearestNode{T<:Union(ENU,ECEF)}(nodes::Dict{Int,T},
                                         loc::T,
                                         node_list::Vector{Int})
    min_dist = Inf
    best_ind = 0

    for ind in node_list
        dist = distance(nodes[ind], loc)
        if dist < min_dist
            min_dist = dist
            best_ind = ind
        end
    end

    return best_ind
end

### Add a new node ###
function addNewNode{T<:Union(LLA,ENU)}(nodes::Dict{Int,T}, loc::T)
    id = 1
    while id <= typemax(Int)
        if !haskey(nodes, id)
            nodes[id] = loc
            return id
        end
        id += 1
    end

    msg = "Unable to add new node to map, $(typemax(Int)) nodes is the current limit."
    throw(OverflowError(msg))
end
