### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for finding highway intersections ###

### Generate a list of intersections ###
function findIntersections(highways::Dict{Int,Highway})
    intersections = Dict{Int,Intersection}()
    crossings = Int[]

    # Highway ends
    for (k, highway_k) in highways
        node0 = highway_k.nodes[1]
        node1 = highway_k.nodes[end]
        nodes = [node0, node1]
        for node in nodes
            if haskey(intersections, node)
                intersections[node] = Intersection(union(intersections[node].highways, Set(k)))
            else
                intersections[node] = Intersection(Set(k))
            end
        end
    end

    # Highway crossings
    for (i, highway_i) in highways
        for j in keys(highways)
            if i > j
                node = intersect(highway_i.nodes, highways[j].nodes)
                for node_id in node
                    if haskey(intersections, node_id)
                        intersections[node_id] = Intersection(union(intersections[node_id].highways, Set(i, j)))
                    else
                        intersections[node_id] = Intersection(Set(i, j))
                    end
                    push!(crossings, node_id)
                end
            end
        end
    end



    return intersections, unique(crossings)
end


### Generate a new list of highways divided up by intersections
function segmentHighways(nodes, highways, intersections, classes, levels=Set(1:10))
    segments = Segment[]
    inters = Set(keys(intersections))

    for (i, class) in classes
        if in(class, levels)
            highway = highways[i]
            first = 1
            for j = 2:length(highway.nodes)
                if in(highway.nodes[j], inters) || j == length(highway.nodes)
                    node0 = highway.nodes[first]
                    node1 = highway.nodes[j]
                    route_nodes = highway.nodes[first:j]
                    dist = distance(nodes, route_nodes)
                    s = Segment(node0, node1, route_nodes, dist, class, i, true)
                    push!(segments, s)

                    if !highway.oneway
                        s = Segment(node1, node0, reverse(route_nodes), dist, class, i, true)
                        push!(segments, s)
                    end
                    first = j
                end
            end
        end
    end

    return segments
end


### Generate a list of highways from segments, for plotting purposes
function highwaySegments(segments::Vector{Segment})
    highways = Dict{Int,Highway}()

    for k = 1:length(segments)
        highways[k] = Highway("", 1, true, "", "", "", "$(segments[k].parent)", segments[k].nodes)
    end

    return highways
end
