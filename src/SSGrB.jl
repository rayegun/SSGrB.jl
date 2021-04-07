module SSGrB

using Libdl: dlopen, dlsym
using SSGraphBLAS_jll: libgraphblas
using CEnum
include("abstracts.jl")
include("enums.jl")
include("exceptions.jl")
include("utils.jl")
include("types.jl")
include("unaryops.jl")
include("binaryops.jl")
include("monoids.jl")
include("selectops.jl")
include("semirings.jl")
include("context.jl")

graphblas_lib = C_NULL

function __init__()
    global graphblas_lib = dlopen(libgraphblas; throw_error=false)

    loadunaryops()
    loadbinaryops()
    loadmonoids()
    loadselectops()
    loadsemirings()
    load_globaltypes()

    GxB_init(GrB_BLOCKING)
end



end
