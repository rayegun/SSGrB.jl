module SSGrB
using Libdl: dlsym
using SSGraphBLAS_jll
using SparseArrays

export GBScalar, GBVector, build, findnz, nnz, libgb, clear

include("abstracts.jl")
include("utils.jl")
include("lib/LibGraphBLAS.jl")
using .libgb

include("Containers.jl")
using .Containers

include("types.jl")
include("monoids.jl")
using .Monoids
include("binaryops.jl")
using .BinaryOps
include("unaryops.jl")
using .UnaryOps
include("semirings.jl")
using .Semirings
include("selectops.jl")
using .SelectOps
include("scalar.jl")
include("vector.jl")
function __init__()
    createunaryops()
    createbinaryops()
    createmonoids()
    loadselectops()
    createsemirings()
    load_globaltypes()
    libgb.GxB_init(libgb.GrB_BLOCKING, cglobal(:jl_malloc), cglobal(:jl_calloc), cglobal(:jl_realloc), cglobal(:jl_free), true)
end
end
