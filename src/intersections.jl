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
                if highway.nodes[first] != highway.nodes[j] && (in(highway.nodes[j], inters) || j == length(highway.nodes))
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


### Cluster highway intersections into higher-level intersections ###
function findIntersectionClusters(nodes, intersections_in, highway_clusters; max_dist=15.0)
    hwy_cluster_mapping = Dict{Int,Int}()
    for k = 1:length(highway_clusters)
        hwys = [highway_clusters[k].highways...]
        for kk = 1:length(hwys)
            hwy_cluster_mapping[hwys[kk]] = k
        end
    end

    # Deep copy intersections dictionary and replace highways with highway 
    # clusters where available
    intersections = deepcopy(intersections_in)
    for (node,inter) in intersections
        hwys = [inter.highways...]
        for k = 1:length(hwys)
            if haskey(hwy_cluster_mapping,hwys[k])
                hwys[k] = hwy_cluster_mapping[hwys[k]]
            end
        end
        inter.highways = Set(hwys)
    end

    # Group intersections by number of streets contained
    hwy_counts = Vector{Int}[]
    for (node,inter) in intersections
        hwy_cnt = length(inter.highways)
        if hwy_cnt > length(hwy_counts)
            for k = (length(hwy_counts)+1):hwy_cnt
                push!(hwy_counts,Int[])
            end
        end
        push!(hwy_counts[hwy_cnt], node)
    end

    cluster_mapping = Dict{Int,Int}()
    clusters = Set{Int}[]
    clusters_nodes = Set{Int}[]

    for kk = 1:(length(hwy_counts)-1)
        k = length(hwy_counts)+1-kk
        # Skip intersections with only 1 highway (road ends)

        for inter in hwy_counts[k]
            found = false
            for index = 1:length(clusters)
                if issubset(intersections[inter].highways,clusters[index])
                    # Check distance to cluster centroid
                    c = centroid(nodes,[clusters_nodes[index]...])
                    dist = distance(c,nodes[inter])
                    if dist < max_dist
                        cluster_mapping[inter] = index
                        clusters_nodes[index] = Set([clusters_nodes[index]...,inter])
                        found = true
                        break
                    end
                end
            end
            if !found
                push!(clusters,intersections[inter].highways)
                push!(clusters_nodes,Set(inter))
                cluster_mapping[inter] = length(clusters)
            end
        end
    end

    cluster_nodes = Int[]
    cluster_map = Dict{Int,Int}()
    for k = 1:length(clusters_nodes)
        if length(clusters_nodes[k]) > 1
            n = [clusters_nodes[k]...]
            c = centroid(nodes,n)
            push!(cluster_nodes,addNewNode(nodes,c))

            for j = 1:length(n)
                cluster_map[n[j]] = cluster_nodes[end]
            end

            if false
                println("#####")
                nds = [clusters_nodes[k]...]
                for kk = 1:length(nds)
                    println("node: $(nds[kk]), loc: $(nodes[nds[kk]]), dist: $(distance(nodes,cluster_nodes[end],nds[kk]))")
                end
                println("centroid: $c")
                println("node ID: $(cluster_nodes[end])")
            end
        end
    end

    return cluster_map, cluster_nodes
end


### Replace Nodes in Highways Using Node Remapping
function replaceHighwayNodes!(highways::Dict{Int,Highway}, node_map::Dict{Int,Int})
    for (key,hwy) in highways
        all_equal = true
        for k = 1:length(hwy.nodes)
            if haskey(node_map,hwy.nodes[k])
                hwy.nodes[k] = node_map[hwy.nodes[k]]
            end

            if k > 1 && hwy.nodes[k] != hwy.nodes[k-1]
                all_equal = false
            end
        end

        # If all nodes in hwy are now equal, delete it.
        if all_equal
            delete!(highways,key)
        end
    end
    return nothing
end


