###################################
### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###
###################################

### Functions for simulating generic OpenStreetMap-format cities. ###

### Grid-based city ###
function simCityGrid(classes_north, classes_east)
    # classes_north: Street classes for north/south streets
    # classes_east: Street classes for east/west streets

    # Initialize data structures
    nodes = Dict{Int,ENU}()
    highways = Dict{Int,Highway}()
    roadways = Dict{Int,Int}()

    # Form a grid of nodes
    N = length(classes_north) # Number of columns
    M = length(classes_east) # Number of rows

    kk = 0
    for n = 1:N
        for m = 1:M
            kk += 1
            nodes[kk] = ENU(n*100, m*100, 0)
        end
    end

    # Form highways
    k = 0 # Highway ID counter
    for n = 1:N
        k += 1
        col_nodes = @compat( collect( (n*M-(M-1)):n*M ) )
        highways[k] = Highway("", 1, false, "", "", "", "North_$(n)", col_nodes)
        roadways[k] = classes_north[n]
    end

    for m = 1:M
        k += 1
        row_nodes = @compat( collect(m:M:N*M) )
        highways[k] = Highway("", 1, false, "", "", "", "East_$(m)", row_nodes)
        roadways[k] = classes_east[m]
    end

    return nodes, highways, roadways
end
