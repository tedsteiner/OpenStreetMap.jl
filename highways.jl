### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Create list of all highways in OSM file ###
function getHighways( street_map::LightXML.XMLDocument )

    xroot = LightXML.root(street_map)
    ways = LightXML.get_elements_by_tagname(xroot, "way")

    highways = Highway[]

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

                        highway = getHighwayData(way,class)
                        push!(highways,highway)
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
    nodes = Int64[]
    road_name = ""

    # Get way ID
    id = int64(LightXML.attribute(highway, "id"))

    # Iterate over all "label" fields
    for label in LightXML.child_elements(highway)

        if LightXML.name(label) == "tag" && LightXML.has_attribute(label, "k")
            k = LightXML.attribute(label, "k")

            # If empty, find the class type
            if class == "" && k == "highway"
                if LightXML.has_attribute(label, "v")
                    class = LightXML.attribute(label, "v")
                    continue
                end
            end

            # Check if street is oneway
            if !oneway && k == "oneway"
                if LightXML.has_attribute(label, "v")
                    v = LightXML.attribute(label, "v")
                    if v == "yes"
                        oneway = true
                        continue
                    end
                end
            end

            # Check if street has a name
            if road_name == "" && k == "name"
                if LightXML.has_attribute(label, "v")
                    road_name = LightXML.attribute(label, "v")
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

    return Highway(id, class, oneway, road_name, nodes)
end
