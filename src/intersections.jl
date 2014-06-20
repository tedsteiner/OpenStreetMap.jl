### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for finding highway intersections ###

### Generate a list of intersections ###
function findIntersections(highways::Dict{Int,Highway})
    intersections = Dict{Int,Intersection}()

    for i in keys(highways)
        for j in keys(highways)
            if i > j
                node = intersect(highways[i].nodes,highways[j].nodes)
                for k = 1:length(node)
                    node_id = node[k]
                    if haskey(intersections, node_id)
                        intersections[node_id] = Intersection(union(intersections[node_id].highways, Set(i,j)))
                    else
                        intersections[node_id] = Intersection( Set(i, j) )
                    end
                end
            end
        end
    end

    return intersections
end
