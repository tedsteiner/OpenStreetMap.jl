### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Get dictionary of all nodes from an OSM XML file ###
function getNodes( street_map::LightXML.XMLDocument )

    xroot = LightXML.root(street_map)
    all_nodes = LightXML.get_elements_by_tagname(xroot, "node")
    nodes = Dict{Int,LatLon}()

    for n = 1:length(all_nodes)
        node = all_nodes[n]

        id = int(LightXML.attribute(node, "id"))
        lat = float(LightXML.attribute(node, "lat"))
        lon = float(LightXML.attribute(node, "lon"))

        nodes[id] = LatLon(lat,lon)
    end

    return nodes
end
