### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for finding highway intersections ###

### Generate a list of intersections ###
function findIntersections(highways::Dict{Int,Highway})
    intersections = Dict{Int,Intersection}()
    
    # Highway ends
    for k in keys(highways)
        node0 = highways[k].nodes[1]
        node1 = highways[k].nodes[end]
        nodes = [node0,node1]
        for kk = 1:length(nodes)
            node = nodes[kk]
            if haskey(intersections, node)
                intersections[node] = Intersection(union(intersections[node].highways, Set(k)))
            else
                intersections[node] = Intersection( Set(k) )
            end
        end
    end
    
    # Highway crossings
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


### Generate a new list of highways divided up by intersections
function segmentHighways( highways, intersections, classes, levels=Set(1:10...) )
    segments = Segment[]
    inters = collect(keys(intersections))
    
    for i in keys(highways)
        if in(classes[i],levels)
            first = 1
            for j = 2:length(highways[i].nodes)            
                if in(highways[i].nodes[j],inters) || j == length(highways[i].nodes)
                    node0 = highways[i].nodes[first]
                    node1 = highways[i].nodes[j]
                    class = classes[i]
                    s = Segment(node0, node1, highways[i].nodes[first:j], class, i, highways[i].oneway)
                    push!(segments,s)
                    first = j
                end
            end
        end
    end
    
    return segments
end
