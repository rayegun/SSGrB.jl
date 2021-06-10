module SSGrB
using SSGraphBLAS_jll: libgraphblas_handle
using Libdl: dlsym
using SSGraphBLAS_jll
using SparseArrays
using MacroTools
using LinearAlgebra
using Random: randsubseq, default_rng, AbstractRNG
import LinearAlgebra: transpose, Transpose, mul!, kron, kron!
export GBScalar, GBVector, GBMatrix, libgb
export build, findnz, nnz,  clear!, transpose, copy!
export BinaryOps, UnaryOps, Monoids, Semirings, Descriptors, SelectOps

include("abstracts.jl")
include("utils.jl")
include("lib/LibGraphBLAS.jl")
using .libgb

include("types.jl")
using .Types

include("gbtype.jl")
include("structures/monoids.jl")
using .Monoids
include("structures/binaryops.jl")
using .BinaryOps
include("structures/unaryops.jl")
using .UnaryOps
include("structures/semirings.jl")
using .Semirings
include("structures/selectops.jl")
using .SelectOps
include("indexutils.jl")
include("scalar.jl")
include("vector.jl")
include("matrix.jl")
include("structures/descriptor.jl")
include("operations/mul.jl")
include("operations/elementwise.jl")
include("operations/apply.jl")
include("operations/reduce.jl")
include("operations/transpose.jl")
include("operations/kronecker.jl")
include("operations/select.jl")
include("rand.jl")
include("import.jl")
include("export.jl")
function __init__()
    createunaryops()
    createbinaryops()
    createmonoids()
    createsemirings()
    load_globaltypes()
    loadselectops()
    loaddescriptors()
    #I don't need these cglobals for the import/export? That's surprising...?
    # Using them gives me a segfault on garbage collection.
    #libgb.GxB_init(libgb.GrB_BLOCKING, cglobal(:jl_malloc), cglobal(:jl_calloc), cglobal(:jl_realloc), cglobal(:jl_free), true)
    libgb.GrB_init(libgb.GrB_NONBLOCKING)
    @eval(Descriptors, $:(const NULL = Descriptor()))
    atexit() do
        libgb.GrB_finalize()
    end
end
end


#TODO:
# resize
# Infixes
# Types v2
#   Positionals
#   UDTs
#   Better hierarchy
# Printing v1 for all types
# Export of CSC/Dense
# @with macro v1
# Get/Set for non-descriptors
# Tests
# Docs
# FIX IMPORTS/USINGS/EXPORTS

#TODO for 1.next/2.0:
# Import/Export every other type
# Printing v2
