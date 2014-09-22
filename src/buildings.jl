### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Create list of all buildings in OSM file ###
function getBuildings(street_map::LightXML.XMLDocument)

    xroot = LightXML.root(street_map)
    ways = LightXML.get_elements_by_tagname(xroot, "way")

    buildings = Dict{Int,Building}()

    for way in ways

        if LightXML.has_attribute(way, "visible")
            if LightXML.attribute(way, "visible") == "false"
                # Visible=false indicates historic data, which we will ignore
                continue
            end
        end

        # Search for tag with k="building"
        for tag in LightXML.child_elements(way)
            if LightXML.name(tag) == "tag"
                if LightXML.has_attribute(tag, "k")
                    k = LightXML.attribute(tag, "k")
                    if k == "building"
                        class = ""
                        if LightXML.has_attribute(tag, "v")
                            class = LightXML.attribute(tag, "v")
                        end

                        id = int(LightXML.attribute(way, "id"))
                        buildings[id] = getBuildingData(way, class)
                        break
                    end
                end
            end
        end
    end

    return buildings
end

### Gather highway data from OSM element ###
function getBuildingData(building::LightXML.XMLElement, class::String="")
    nodes = Int[]
    class = ""
    building_name = ""

    # Get way ID
    # id = int64(LightXML.attribute(building, "id"))

    # Iterate over all "label" fields
    for label in LightXML.child_elements(building)

        if LightXML.name(label) == "tag" && LightXML.has_attribute(label, "k")
            k = LightXML.attribute(label, "k")

            # If not yet set, find the class type
            if class == "" && k == "building"
                if LightXML.has_attribute(label, "v")
                    class = LightXML.attribute(label, "v")
                    continue
                end
            end

            # Check if building has a name
            if building_name == "" && k == "name"
                if LightXML.has_attribute(label, "v")
                    building_name = LightXML.attribute(label, "v")
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

    return Building(class, building_name, nodes)
end

### Classify buildings ###
function classify(buildings::Dict{Int,Building})
    bdgs = Dict{Int,Int}()

    for (key, building) in buildings
        if haskey(BUILDING_CLASSES, building.class)
            bdgs[key] = BUILDING_CLASSES[building.class]
        end
    end

    return bdgs
end
