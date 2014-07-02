### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for finding highway intersections ###

### Generate a list of intersections ###
# Unique_only flag: This removes intersections likely to be caused by two one-way highways following the same path of nodes
function findIntersections(highways::Dict{Int,Highway}, unique_only=true )
    intersections = Dict{Int,Intersection}()
    unique = Dict{Int,Bool}()

    for i in keys(highways)
        for j in keys(highways)
            if i > j
                node = intersect(highways[i].nodes,highways[j].nodes) # All common nodes
                for k = 1:length(node)
                    if length(node) > 1
                        println("node = $(node)")
                    end
                    node_id = node[k]

                    # Add to intersections
                    if haskey(intersections, node_id)
                        intersections[node_id] = Intersection(union(intersections[node_id].highways, Set(i,j)))
                        if length(intersections[node_id].highways) > 2 && !unique[node_id]
                            unique[node_id] = true
                        end
                    else
                        intersections[node_id] = Intersection( Set(i, j) )

                        if length(node) > 1
                            # If two streets have multiple crossings with each other, we say the intersection is not unique.
                            # This is typically cases like a boulevard, which are modeled as two one-way highways
                            unique[node_id] = false
                            println("Unique false")
                        else
                            if highways[i].name == highways[j].name && highways[i].name != ""
                                println(highways[i].name)
                                unique[node_id] = false
                            else
                                unique[node_id] = true
                            end
                        end
                    end
                end
            end
        end
    end

    if unique_only
        for key in keys(intersections)
            if !unique[key]
                println("Removeing non-unique intersection $(key).")
                delete!(intersections,key)
            end
        end
    end

    return intersections
end
