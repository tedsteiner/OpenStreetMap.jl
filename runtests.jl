
tests = [
    "read_data" ]


for t in tests
    tp = joinpath("tests", "$(t).jl")
    println("running $(tp) ...")
    include(tp)
end

