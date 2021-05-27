module SSGrB
using Libdl: dlsym
using SSGraphBLAS_jll
import SparseArrays: nnz
include("lib/LibGraphBLAS.jl")
using .libgb
include("abstracts.jl")
include("Containers.jl")
using .Containers
include("utils.jl")
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
