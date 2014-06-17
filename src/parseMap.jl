### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Parse the data from an openStreetMap XML file ###
function parseMapXML( filename::String )

    # Parse the file
    street_map = LightXML.parse_file(filename)

    # get the root element
    #xroot = LightXML.root(street_map)   # an instance of XMLElement
    # print its name
    #println(LightXML.name(xroot))  # this should print: osm

    if LightXML.name(LightXML.root(street_map)) != "osm"
        println("Warning: Not an OpenStreetMap datafile.")
    end

    return street_map
end
