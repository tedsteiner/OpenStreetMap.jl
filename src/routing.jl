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


### Get list of highway edges ###
function createGraph( nodes, highways, classes, levels )
    v = Dict{Int,Graphs.KeyVertex{Int}}()                      # Vertices
    v_inv = Int[]
    e = Set()                                                  # Edges
    w = Float64[]                                              # Weights
    g = Graphs.inclist(Graphs.KeyVertex{Int},is_directed=true) # Graph

    verts = [highwayVertices( highways, classes, levels )...]
    for k = 1:length(verts)
        v[verts[k]] = Graphs.add_vertex!(g,verts[k])
        push!(v_inv,verts[k])
    end

    for key in keys(classes)
        if in(classes[key],levels)
            if length(highways[key].nodes) > 1
                # Add edges to graph and compute weights
                for n = 2:length(highways[key].nodes)
                    Graphs.add_edge!(g, v[highways[key].nodes[n-1]], v[highways[key].nodes[n]])
                    weight = distance(nodes, highways[key].nodes[n-1], highways[key].nodes[n])
                    push!(w, weight)

                    if !highways[key].oneway
                        Graphs.add_edge!(g, v[highways[key].nodes[n]], v[highways[key].nodes[n-1]])
                        push!(w, weight)
                    end
                end
            end
        end
    end

    return g, v, w, v_inv
end


### Get distance between two nodes ###
# ENU Coordinates
function distance( nodes::Dict{Int,ENU}, node0, node1 )
    loc0 = nodes[node0]
    loc1 = nodes[node1]

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
