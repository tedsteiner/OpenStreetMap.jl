### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for finding highway intersections ###

### Generate a list of intersections ###
function findIntersections(highways::Array{Highway,1})
    intersections = Dict{Int,Intersection}()

    for i = 1:length(highways)
        for j = i:length(highways)
            if i != j
                node = intersect(highways[i].nodes,highways[j].nodes)
                for k = 1:length(node)
                    node_id = node[k]
                    if haskey(intersections, node_id)
                        intersections[node_id] = Intersection(union(intersections[node_id].highways, Set(highways[i].id,highways[j].id)))
                    else
                        intersections[node_id] = Intersection( Set(highways[i].id, highways[j].id) )
                    end
                end
            end
        end
    end

    return intersections
end
