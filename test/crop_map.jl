# Test cropping OSM data
module TestCropMap

using OpenStreetMap
using Base.Test
using Compat

import OpenStreetMap: Bounds, LLA, aspectRatio, getX, getY, inBounds

MAP_FILENAME = "tech_square.osm"

bounds = Bounds(42.3637, 42.3655, -71.0919, -71.0893)

nodes, hwys, builds, feats = getOSMData(MAP_FILENAME)
cropMap!(nodes, bounds, highways=hwys, buildings=builds, features=feats, delete_nodes=true)
@test length(nodes) == 198
@test length(hwys) == 16
@test length(builds) == 1
@test length(feats) == 0

# cropHighways removes out-of-bounds points and interpolates points on boundary
let bounds = Bounds(0, 1, 0, 1)
    coords = [
        LLA(-0.1, -0.02),
        LLA(0.1, 0.1),
        LLA(0.2, 0.0),
        LLA(0.3, -0.1),
        LLA(0.4, 0.1),
        LLA(1.0, 0.3),
        LLA(2.0, 0.4)
    ]

    hwy = first(values(hwys))
    hwy.nodes = collect(1:length(coords))
    highways = Compat.@Dict(1 => hwy)

    nodes = Dict{Int,LLA}([(hwy.nodes[i], coords[i]) for i in 1:length(coords)])
    cropMap!(nodes, bounds, highways=highways)

    hwy_nodes = highways[1].nodes

    # same changes made to nodes and highways
    @test isempty(symdiff(keys(nodes), hwy_nodes))

    # everything ends up in bounds
    if VERSION.minor < 4
        @test all(map(x -> inBounds(x, bounds), values(nodes)))        
    else
        @test all(x -> inBounds(x, bounds), values(nodes))
    end

    # proper interpolation
    @test getY(nodes[hwy_nodes[1]]) == 0.0
    @test_approx_eq getX(nodes[hwy_nodes[1]]) 0.04

    @test_approx_eq getY(nodes[hwy_nodes[4]]) 0.35
    @test getX(nodes[hwy_nodes[4]]) == 0.0

    @test getY(nodes[hwy_nodes[end]]) == 1.0
    @test_approx_eq getX(nodes[hwy_nodes[end]]) 0.3
end

end # module TestCropMap
