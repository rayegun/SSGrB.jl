module SSGrB
using Libdl: dlsym
using SSGraphBLAS_jll
using SparseArrays
using MacroTools
import LinearAlgebra: mul!
export GBScalar, GBVector, GBMatrix, build, findnz, nnz, libgb, clear, BinaryOps, UnaryOps,
    Monoids, Semirings, Descriptors, SelectOps

include("abstracts.jl")
include("utils.jl")
include("lib/LibGraphBLAS.jl")
using .libgb

include("types.jl")
using .Types

include("gbtype.jl")
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
include("indexutils.jl")
include("scalar.jl")
include("vector.jl")
include("matrix.jl")
include("descriptor.jl")
include("operations/mul.jl")
include("operations/elementwise.jl")
function __init__()
    createunaryops()
    createbinaryops()
    createmonoids()
    createsemirings()
    load_globaltypes()
    loadselectops()
    loaddescriptors()
    libgb.GxB_init(libgb.GrB_BLOCKING, cglobal(:jl_malloc), cglobal(:jl_calloc), cglobal(:jl_realloc), cglobal(:jl_free), true)
    atexit() do
        libgb.GrB_finalize()
    end
end
end
