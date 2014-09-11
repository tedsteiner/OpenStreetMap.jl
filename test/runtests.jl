tests = [
    "read_data",
    "simcity",
    "crop_map",
    "classes",
    "coordinates",
    "routes",
    "plots" ]

for t in tests
    println("testing $t ...")
    @time include("$t.jl")
end
