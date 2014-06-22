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

function getOSMData( filename::String; nodes=false, highways=false, buildings=false, features=false)
    @time street_map = parseMapXML(filename)
    println("Finished parseMapXML.")

    if nodes
        @time nodes = getNodes(street_map)
        println("Finished getNodes")
    end

    if highways
        @time highways = getHighways(street_map)
        println("Finished getHighways")
    end

    if buildings
        @time buildings = getBuildings(street_map)
    end

    if features
        @time features = getFeatures(street_map)
    end

    return nodes, highways, buildings, features
end
