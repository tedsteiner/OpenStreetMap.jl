### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for finding highway intersections ###

### Generate a list of intersections ###
function findIntersections(highways::Dict{Int,Highway})
    intersections = Dict{Int,Intersection}()
    crossings = Int[]
    
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
                    push!(crossings,node_id)
                end
            end
        end
    end
    
    

    return intersections, unique(crossings)
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
                    nodes = highways[i].nodes[first:j]
                    s = Segment(node0, node1, nodes, class, i, true)
                    push!(segments,s)
                    
                    if !highways[i].oneway
                        s = Segment(node1, node0, reverse(nodes), class, i, true)
                        push!(segments,s)
                    end
                    first = j
                end
            end
        end
    end
    
    return segments
end


### Generate a list of highways from segments, for plotting purposes
function highwaySegments( segments )
    highways = Dict{Int,Highway}()
    
    for k = 1:length(segments)
        highways[k] = Highway("",1,true,"","","","$(segments[k].parent)",segments[k].nodes)   
    end
    
    return highways
end
