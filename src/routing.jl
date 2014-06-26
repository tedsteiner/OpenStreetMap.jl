### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Route Planning for OpenStreetMap ###

### Get list of vertices (highway nodes) in specified levels of classes ###
# For all highways
function highwayVertices( highways::Dict{Int,Highway} )
    vertices = Set{Int}()

    for key in keys(highways)
        union!(vertices,highways[key].nodes)
    end

    return vertices
end

# For classified highways
function highwayVertices( highways::Dict{Int,Highway}, classes::Dict{Int,Int} )
    vertices = Set{Int}()

    for key in keys(classes)
        union!(vertices,highways[key].nodes)
    end

    return vertices
end

# For specified levels of a classifier dictionary
function highwayVertices( highways::Dict{Int,Highway}, classes::Dict{Int,Int}, levels )
    vertices = Set{Int}()

    for key in keys(classes)
        if in(classes[key],levels)
            union!(vertices,highways[key].nodes)
        end
    end

    return vertices
end


### Form transportation network graph of map ###
function createGraph( nodes, highways, classes, levels )
    v = Dict{Int,Graphs.KeyVertex{Int}}()                      # Vertices
    e = Graphs.Edge[]                                          # Edges
    w = Float64[]                                              # Weights
    class = Int[]                                              # Road class
    g = Graphs.inclist(Graphs.KeyVertex{Int},is_directed=true) # Graph

    verts = [highwayVertices( highways, classes, levels )...]
    v_inv = zeros(Int,length(verts))                               # Inverse vertex mapping
    for k = 1:length(verts)
        v[verts[k]] = Graphs.add_vertex!(g,verts[k])
        v_inv[k] = verts[k]
    end
    @assert length(v_inv) == length(v)

    for key in keys(classes)
        if in(classes[key],levels)
            if length(highways[key].nodes) > 1
                # Add edges to graph and compute weights
                for n = 2:length(highways[key].nodes)
                    edge = Graphs.make_edge(g, v[highways[key].nodes[n-1]], v[highways[key].nodes[n]])
                    Graphs.add_edge!(g, edge)
                    weight = distance(nodes, highways[key].nodes[n-1], highways[key].nodes[n])
                    push!(w, weight)
                    push!(class, classes[key])
                    push!(e, edge)

                    if !highways[key].oneway
                        edge = Graphs.make_edge(g, v[highways[key].nodes[n]], v[highways[key].nodes[n-1]])
                        Graphs.add_edge!(g, edge)
                        push!(w, weight)
                        push!(class, classes[key])
                        push!(e, edge)
                    end
                end
            end
        end
    end

    return Network(g, v, e, w, v_inv, class)
end


### Get distance between two nodes ###
# ENU Coordinates
function distance( nodes::Dict{Int,ENU}, node0, node1 )
    loc0 = nodes[node0]
    loc1 = nodes[node1]

    return distance( loc0, loc1 )
end

function distance( loc0::ENU, loc1::ENU )
    x0 = loc0.east
    y0 = loc0.north
    z0 = loc0.up

    x1 = loc1.east
    y1 = loc1.north
    z1 = loc1.up

    return distance(x0,y0,z0,x1,y1,z1)
end

# ECEF Coordinates
function distance( nodes::Dict{Int,ECEF}, node0, node1 )
    loc0 = nodes[node0]
    loc1 = nodes[node1]

    return distance( loc0, loc1 )
end

function distance( loc0::ECEF, loc1::ECEF )
    x0 = loc0.x
    y0 = loc0.y
    z0 = loc0.z

    x1 = loc1.x
    y1 = loc1.y
    z1 = loc1.z

    return distance(x0,y0,z0,x1,y1,z1)
end

# Cartesian coordinates
function distance( x0, y0, z0, x1, y1, z1 )
    return sqrt( (x1-x0)^2 + (y1-y0)^2 + (z1-z0)^2 )
end


### Shortest Paths ###
# Dijkstra's Algorithm
function dijkstra( g, w, start_vertex )
    return Graphs.dijkstra_shortest_paths(g, w, start_vertex)
end

# Extract route from Dijkstra results object
function extractRoute( dijkstra::Graphs.DijkstraStates, start_index, finish_index )
    route = Int[]

    distance = dijkstra.dists[finish_index]

    if distance != Inf
        index = finish_index
        push!(route,index)
        while index != start_index
            index = dijkstra.parents[index].index
            push!(route,index)
        end
    end

    return route, distance
end

### Generate an ordered list of edges traversed in route
function routeEdges( network::Network, route )
    e = zeros(Int,length(route)-1)

    # For each node pair, find matching edge
    for n = 1:length(route)-1

        s = network.v[route[n]]
        t = network.v[route[n+1]]

        for k = 1:length(network.e)
            if s == network.e[k].source && t == network.e[k].target
                e[n] = k
            end
        end
    end

    return e
end

### Shortest Route ###
function shortestRoute( network, node0, node1 )
    start_vertex = network.v[node0]

    dijkstra_result = dijkstra( network.g, network.w, start_vertex )

    start_index = network.v[node0].index
    finish_index = network.v[node1].index
    route_indices, distance = extractRoute( dijkstra_result, start_index, finish_index )

    route_nodes = zeros(Int,length(route_indices))
    for n = 1:length(route_indices)
        route_nodes[n] = network.v_inv[route_indices[n]]
    end

    return route_nodes, distance, dijkstra_result
end

### Fastest Route ###
function fastestRoute( network, node0, node1, class_speeds=SPEED_ROADS_URBAN )
    start_vertex = network.v[node0]

    # Modify weights to be times rather than distances
    w = zeros(length(network.w))
    for k = 1:length(w)
        w[k] = network.w[k] / class_speeds[network.class[k]]
        w[k] *= 3.6 # (3600/1000) unit conversion to seconds
    end

    dijkstra_result = dijkstra( network.g, w, start_vertex )

    start_index = network.v[node0].index
    finish_index = network.v[node1].index
    route_indices, route_time = extractRoute( dijkstra_result, start_index, finish_index )

    route_nodes = zeros(Int,length(route_indices))
    for n = 1:length(route_indices)
        route_nodes[n] = network.v_inv[route_indices[n]]
    end

    return route_nodes, route_time
end

### Compute the distance of a route ###
function distance( nodes, route )
    dist = 0
    for n = 2:length(route)
        dist += distance( nodes, route[n-1], route[n] )
    end

    return dist
end
