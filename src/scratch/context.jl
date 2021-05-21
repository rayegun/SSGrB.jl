"""
    GrB_init(mode::GrB_Mode)::GrB_Info


`GrB_init` must called before any other GraphBLAS operation.
`GrB_init` defines the mode that GraphBLAS will use:  blocking or
non-blocking.  With blocking mode, all operations finish before returning to
the user application.  With non-blocking mode, operations can be left
pending, and are computed only when needed.

The extension `GxB_init` does the work of `GrB_init`, but it also defines the
memory management functions that SuiteSparse:GraphBLAS will use internally.
"""

function GrB_init(mode::GrB_Mode)
        checkinfo(ccall(dlsym(graphblas_lib, "GrB_init"), GrB_Info, (GrB_Mode,), mode))
end

function GxB_init(mode::GrB_Mode)
    checkinfo(ccall(dlsym(graphblas_lib, "GxB_init"), GrB_Info, (GrB_Mode,Ptr{Nothing},Ptr{Nothing},Ptr{Nothing},Ptr{Nothing}, Bool), mode, cglobal(:jl_malloc), cglobal(:jl_calloc), cglobal(:jl_realloc), cglobal(:jl_free), true))
end

function GxB_cuda_init(mode::GrB_Mode)
    throw("CUDA support not yet implemented")
end

function GrB_getVersion()
    version = Ref{Cint}(0)
    subversion = Ref{Cint}(0)
    checkinfo(ccall(dlsym(graphblas_lib, "GrB_getVersion"), GrB_Info, (Ref{Cint}, Ref{Cint}), version, subversion))
    return version[], subversion[]
end

function GrB_finalize()
    checkinfo(ccall(dlsym(graphblas_lib, "GrB_finalize"), GrB_Info, ()))
end