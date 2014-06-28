
tests = [
    "read_data",
    "crop_map",
    "classes",
    "coordinates",
    "routes",
    "plots" ]


for t in tests
    tp = joinpath("tests", "$(t).jl")
    println("running $(tp) ...")
    include(tp)
end

