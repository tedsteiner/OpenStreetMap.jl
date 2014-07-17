
tests = [
    "read_data",
    "simcity",
    "crop_map",
    "classes",
    "coordinates",
    "routes",
    "plots" ]


for t in tests
    tp = joinpath("tests", "$(t).jl")
    println("running $(tp) ...")
    @time include(tp)
end

