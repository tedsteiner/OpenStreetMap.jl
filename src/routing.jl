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


