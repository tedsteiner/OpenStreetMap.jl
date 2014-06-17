### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Create list of all buildings in OSM file ###
function getBuildings( street_map::LightXML.XMLDocument )

    xroot = LightXML.root(street_map)
    ways = LightXML.get_elements_by_tagname(xroot, "way")

    buildings = Building[]

    for n = 1:length(ways)
        way = ways[n]
        # TODO: Check if visible?

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

                        building = getBuildingData(way,class)
                        push!(buildings,building)
                        break
                    end
                end
            end
        end

    end

    return buildings
end

### Gather highway data from OSM element ###
function getBuildingData( building::LightXML.XMLElement, class::String="" )
    nodes = Int64[]
    class = ""
    building_name = ""

    # Get way ID
    id = int64(LightXML.attribute(building, "id"))

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
            push!(nodes,int64(LightXML.attribute(label, "ref")))
            continue
        end
    end

    return Building(id, class, building_name, nodes)
end

