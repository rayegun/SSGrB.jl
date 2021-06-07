module SSGrB
using SSGraphBLAS_jll: libgraphblas_handle
using Libdl: dlsym
using SSGraphBLAS_jll
using SparseArrays
using MacroTools
using LinearAlgebra
import LinearAlgebra: transpose, Transpose, mul!, kron, kron!
import SparseArrays: nnz, findnz
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
include("operations/apply.jl")
include("operations/reduce.jl")
include("operations/transpose.jl")
include("operations/kronecker.jl")
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


#TODO before 1.0:
# 2nd pass over all operations for:
#   Proper type promotion/optype
#   Switch defaults from nothing/getoperator to function signature
# Lazy Transpose for all operations
# Kron and Select v2, resize
# Types v2
#   Positionals
#   UDTs
#   Better hierarchy
# Printing v1 for all types
# Import/Export of CSC
# Complete infixes
# @with macro v1
# Get/Set for non-descriptors
# Tests
# Docs
# FIX IMPORTS/USINGS/EXPORTS

#TODO for 1.next/2.0:
# Import/Export every other type
# Printing v2
#
