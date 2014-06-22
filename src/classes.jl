### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### The following dictionaries are used for grouping ways    ###
### into limited, discrete classes for routing and plotting. ###

# Ordered by typical significance
const ROAD_CLASSES = [ "motorway"=>1,
                       "trunk"=>2,
                       "primary"=>3,
                       "secondary"=>4,
                       "tertiary"=>5,
                       "unclassified"=>6,
                       "residential"=>6,
                       "service"=>7,
                       "motorway_link"=>1,
                       "trunk_link"=>2,
                       "primary_link"=>3,
                       "secondary_link"=>4,
                       "tertiary_link"=>5,
                       "living_street"=>8,
                       "pedestrian"=>8,
                       "road"=>6 ]

# Level 1: Cycleways, walking paths, and pedestrian streets
# Level 2: Sidewalks
# Level 3: Pedestrians typically allowed but unspecified
# Level 4: Agricultural or horse paths, etc.
const PED_CLASSES = [ "cycleway"=>1,
                      "pedestrian"=>1,
                      "living_street"=>1,
                      "footway"=>1,
                      "sidewalk"=>2,
                      "sidewalk:yes"=>2,
                      "sidewalk:both"=>2,
                      "sidewalk:left"=>2,
                      "sidewalk:right"=>2,
                      "steps"=>2,
                      "path"=>3,
                      "residential"=>3,
                      "service"=>3,
                      "secondary"=>4,
                      "tertiary"=>4,
                      "primary"=>4,
                      "track"=>4,
                      "bridleway"=>4,
                      "unclassified"=>4 ]

# Level 1: Bike paths
# Level 2: Separated bike lanes (tracks)
# Level 3: Bike lanes
# Level 4: Bikes typically allowed but not specified
const CYCLE_CLASSES = [ "cycleway"=>1,
                        "cycleway:track"=>2,
                        "cycleway:opposite_track"=>2,
                        "cycleway:lane"=>3,
                        "cycleway:opposite"=>3,
                        "cycleway:opposite_lane"=>3,
                        "cycleway:shared"=>3,
                        "cycleway:share_busway"=>3,
                        "cycleway:shared_lane"=>3,
                        "bicycle:use_sidepath"=>2,
                        "bicycle:designated"=>2,
                        "bicycle:permissive"=>3,
                        "bicycle:yes"=>3,
                        "bicycle:dismount"=>4,
                        "residential"=>4,
                        "pedestrian"=>4,
                        "living_street"=>4,
                        "service"=>4,
                        "unclassified"=>4 ]
