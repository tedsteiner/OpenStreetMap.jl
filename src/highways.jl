### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Create list of all highways in OSM file ###
function getHighways( street_map::LightXML.XMLDocument )

    xroot = LightXML.root(street_map)
    ways = LightXML.get_elements_by_tagname(xroot, "way")

    highways = Dict{Int,Highway}()

    for n = 1:length(ways)
        way = ways[n]
        # TODO: Check if visible?

        # Search for tag with k="highway"
        for tag in LightXML.child_elements(way)
            if LightXML.name(tag) == "tag"
                if LightXML.has_attribute(tag, "k")
                    k = LightXML.attribute(tag, "k")
                    if k == "highway"
                        class = ""
                        if LightXML.has_attribute(tag, "v")
                            class = LightXML.attribute(tag, "v")
                        end

                        id = int(LightXML.attribute(way, "id"))
                        highways[id] = getHighwayData(way,class)
                        break
                    end
                end
            end
        end

    end

    return highways
end

### Gather highway data from OSM element ###
function getHighwayData( highway::LightXML.XMLElement, class::String="" )
    oneway = false
    oneway_override = false # Flag to indicate if oneway is forced to false
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
            if class == "" && k == "highway"
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
                    end
                    continue
                end
            end

            # Check if street has a name
            if road_name == "" && k == "name"
                if LightXML.has_attribute(label, "v")
                    road_name = LightXML.attribute(label, "v")
                    continue
                end
            end

            # Check for cycleway
            if cycleway == "" && k == "cycleway"
                if LightXML.has_attribute(label, "v")
                    cycleway = LightXML.attribute(label, "v")
                    continue
                end
            end

            # Check for sidewalk
            if sidewalk == "" && k == "sidewalk"
                if LightXML.has_attribute(label, "v")
                    sidewalk = LightXML.attribute(label, "v")
                    continue
                end
            end

            # Check for number of lanes
            if lanes == 1 && k == "lanes"
                if LightXML.has_attribute(label, "v")
                    lane_str = LightXML.attribute(label, "v")
                    if lane_str=="1" || lane_str=="2" || lane_str=="3" || lane_str=="4" || lane_str=="5" || lane_str=="6" || lane_str=="7" || lane_str=="8" || lane_str=="9"
                        lanes = int(lane_str)
                    end
                    continue
                end
            end
        end

        # Collect associated nodes
        if LightXML.name(label) == "nd" && LightXML.has_attribute(label, "ref")
            push!(nodes,int64(LightXML.attribute(label, "ref")))
            continue
        end
    end

    return Highway(class, lanes, oneway, sidewalk, cycleway, bicycle, road_name, nodes)
end

### Classify highways for cars ###
function roadways( highways::Dict{Int,Highway} )
    roads = Dict{Int,Int}()

    for key in keys(highways)
        if haskey(ROAD_CLASSES,highways[key].class)
            roads[key] = ROAD_CLASSES[highways[key].class]
        end
    end

    return roads
end

### Classify highways for pedestrians ###
function walkways( highways::Dict{Int,Highway} )
    peds = Dict{Int,Int}()

    for key in keys(highways)
        if highways[key].sidewalk != "no"
            # Field priority: sidewalk, highway
            if haskey(PED_CLASSES,"sidewalk:$(highways[key].sidewalk)")
                peds[key] = PED_CLASSES["sidewalk:$(highways[key].sidewalk)"]
            elseif haskey(PED_CLASSES,highways[key].class)
                peds[key] = PED_CLASSES[highways[key].class]
            end
        end
    end

    return peds
end

### Classify highways for cycles ###
function cycleways( highways::Dict{Int,Highway} )
    cycles = Dict{Int,Int}()

    for key in keys(highways)
        if highways[key].bicycle != "no"
            # Field priority: cycleway, bicycle, highway
            if haskey(CYCLE_CLASSES,"cycleway:$(highways[key].cycleway)")
                cycles[key] = CYCLE_CLASSES["cycleway:$(highways[key].cycleway)"]
            elseif haskey(CYCLE_CLASSES,"bicycle:$(highways[key].bicycle)")
                cycles[key] = CYCLE_CLASSES["bicycle:$(highways[key].bicycle)"]
            elseif haskey(CYCLE_CLASSES,highways[key].class)
                cycles[key] = CYCLE_CLASSES[highways[key].class]
            end
        end
    end

    return cycles
end
