mutable struct GrB_Scalar{T} <: Abstract_GrB_Struct
    p::Ptr{Cvoid}
end

function GrB_Scalar{T}() where {T}
    GrB_Scalar{T}(C_NULL)
    

function GxB_Scalar_new(S::GrB_Scalar{T})
    S_ptr = pointer_from_objref(S)

    checkinfo(
        ccall(
            dlsym(graphblas_lib, "GrB_Scalar_new"),
            GrB_Info,
            (Ptr{Cvoid}, Ptr{Cvoid}),

        )
    )