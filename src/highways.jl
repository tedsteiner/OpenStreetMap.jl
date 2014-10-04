### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Create list of all highways in OSM file ###
function getHighways(street_map::LightXML.XMLDocument)

    xroot = LightXML.root(street_map)
    ways = LightXML.get_elements_by_tagname(xroot, "way")

    highways = Dict{Int,Highway}()

    for way in ways

        if LightXML.has_attribute(way, "visible")
            if LightXML.attribute(way, "visible") == "false"
                # Visible=false indicates historic data, which we will ignore
                continue
            end
        end

        # Search for tag with k="highway"
        for tag in LightXML.child_elements(way)
            if LightXML.name(tag) == "tag"
                if LightXML.has_attribute(tag, "k")
                    k = LightXML.attribute(tag, "k")
                    if k == "highway"
                        if LightXML.has_attribute(tag, "v")
                            class = LightXML.attribute(tag, "v")

                            # Note: Highways marked "services" are not traversable
                            if class != "services"
                                id = int(LightXML.attribute(way, "id"))
                                highways[id] = getHighwayData(way, class)
                            end
                        end
                        break
                    end
                end
            end
        end

    end

    return highways
end

### Gather highway data from OSM element ###
function getHighwayData(highway::LightXML.XMLElement, class::String="")
    oneway = false
    oneway_override = false # Flag to indicate if oneway is forced to false
    oneway_reverse = false # Flag to indicate nodes need to be reversed
    nodes = Int[]
    road_name = ""
    cycleway = ""
    sidewalk = ""
    bicycle = ""
    lanes = 1

    # Get way ID
    # id = int(LightXML.attribute(highway, "id"))

    # Iterate over all "label" fields
    for label in LightXML.child_elements(highway)

        if LightXML.name(label) == "tag" && LightXML.has_attribute(label, "k")
            k = LightXML.attribute(label, "k")

            # If empty, find the class type
            if isempty(class) && k == "highway"
                if LightXML.has_attribute(label, "v")
                    class = LightXML.attribute(label, "v")
                    if !oneway_override
                        if class == "motorway" || class == "motorway_link"
                            # Motorways default to oneway
                            oneway = true
                        end
                    end
                    continue
                end
            end

            # Check if street is oneway
            if k == "oneway"
                if LightXML.has_attribute(label, "v")
                    v = LightXML.attribute(label, "v")
                    if v == "yes" || v == "true" || v == "1"
                        if !oneway_override
                            oneway = true
                        end
                    elseif v == "no" || v == "false" || v == "0"
                        oneway = false
                        oneway_override = true
                    elseif v == "-1"
                        oneway = true
                        oneway_reverse = true
                    end
                    continue
                end
            end

            # Roundabouts are oneway
            if k == "junction"
                if LightXML.has_attribute(label, "v")
                    v = LightXML.attribute(label, "v")
                    if v == "roundabout" && !oneway_override
                        oneway = true
                    end
                    continue
                end
            end

            # Check if street has a name
            if isempty(road_name) && k == "name"
                if LightXML.has_attribute(label, "v")
                    road_name = LightXML.attribute(label, "v")
                    continue
                end
            end

            # Check for cycleway
            if isempty(cycleway) && k == "cycleway"
                if LightXML.has_attribute(label, "v")
                    cycleway = LightXML.attribute(label, "v")
                    continue
                end
            end

            # Check for sidewalk
            if isempty(sidewalk) && k == "sidewalk"
                if LightXML.has_attribute(label, "v")
                    sidewalk = LightXML.attribute(label, "v")
                    continue
                end
            end

            # Check for number of lanes
            if lanes == 1 && k == "lanes"
                if LightXML.has_attribute(label, "v")
                    lane_str = LightXML.attribute(label, "v")
                    if length(lane_str) == 1 && '1' <= lane_str[1] <= '9'
                        lanes = int(lane_str)
                    end
                    continue
                end
            end
        end

        # Collect associated nodes
        if LightXML.name(label) == "nd" && LightXML.has_attribute(label, "ref")
            push!(nodes, int64(LightXML.attribute(label, "ref")))
            continue
        end
    end

    # If road is marked as backwards (should be rare), reverse the node order
    if oneway_reverse
        reverse!(nodes)
    end


    return Highway(class, lanes, oneway, sidewalk, cycleway, bicycle, road_name, nodes)
end

### Classify highways for cars ###
function roadways(highways::Dict{Int,Highway})
    roads = Dict{Int,Int}()

    for (key, highway) in highways
        if haskey(ROAD_CLASSES, highway.class)
            roads[key] = ROAD_CLASSES[highway.class]
        end
    end

    return roads
end

### Classify highways for pedestrians ###
function walkways(highways::Dict{Int,Highway})
    peds = Dict{Int,Int}()

    for (key, highway) in highways
        if highway.sidewalk != "no"
            # Field priority: sidewalk, highway
            if haskey(PED_CLASSES, "sidewalk:$(highway.sidewalk)")
                peds[key] = PED_CLASSES["sidewalk:$(highway.sidewalk)"]
            elseif haskey(PED_CLASSES, highway.class)
                peds[key] = PED_CLASSES[highway.class]
            end
        end
    end

    return peds
end

### Classify highways for cycles ###
function cycleways(highways::Dict{Int,Highway})
    cycles = Dict{Int,Int}()

    for (key, highway) in highways
        if highway.bicycle != "no"
            # Field priority: cycleway, bicycle, highway
            if haskey(CYCLE_CLASSES, "cycleway:$(highway.cycleway)")
                cycles[key] = CYCLE_CLASSES["cycleway:$(highway.cycleway)"]
            elseif haskey(CYCLE_CLASSES, "bicycle:$(highway.bicycle)")
                cycles[key] = CYCLE_CLASSES["bicycle:$(highway.bicycle)"]
            elseif haskey(CYCLE_CLASSES, highway.class)
                cycles[key] = CYCLE_CLASSES[highway.class]
            end
        end
    end

    return cycles
end
