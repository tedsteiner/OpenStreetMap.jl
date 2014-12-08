### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Functions for finding highway intersections ###

### Generate a list of intersections ###
function findIntersections(highways::Dict{Int,Highway})
    seen = Set{Int}()
    intersections = Dict{Int,Intersection}()

    for hwy in values(highways)
        n_nodes = length(hwy.nodes)

        for i in 1:n_nodes
            node = hwy.nodes[i]

            if i == 1 || i == n_nodes || in(node, seen)
                get!(Intersection, intersections, node)
            else
                push!(seen, node)
            end
        end
    end

    for (hwy_key, hwy) in highways
        n_nodes = length(hwy.nodes)

        for i in 1:n_nodes
            node = hwy.nodes[i]

            if i == 1 || i == n_nodes || haskey(intersections, node)
                push!(intersections[node].highways, hwy_key)
            end
        end
    end

    return intersections
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
