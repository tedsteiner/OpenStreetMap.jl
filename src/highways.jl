### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

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
