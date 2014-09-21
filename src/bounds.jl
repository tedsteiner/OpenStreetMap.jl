### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Get bounds of mapped region ###
function getBounds(street_map::LightXML.XMLDocument)

    xroot = LightXML.root(street_map)
    bounds = LightXML.get_elements_by_tagname(xroot, "bounds")

    min_lat = float(LightXML.attribute(bounds[1], "minlat"))
    max_lat = float(LightXML.attribute(bounds[1], "maxlat"))
    min_lon = float(LightXML.attribute(bounds[1], "minlon"))
    max_lon = float(LightXML.attribute(bounds[1], "maxlon"))

    return Bounds(min_lat, max_lat, min_lon, max_lon)
end
