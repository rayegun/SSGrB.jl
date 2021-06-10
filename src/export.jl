function exportdensematrix(A::GBMatrix{T};
    desc::Descriptor = Descriptors.NULL
) where {T}
    nrows = Ref{libgb.GrB_Index}(size(A,1))
    ncols = Ref{libgb.GrB_Index}(size(A,2))
    Csize = Ref{libgb.GrB_Index}(length(A) * sizeof(T))
    Cx = Ptr{T}(Libc.malloc(length(A) * sizeof(T)))
    CRef = Ref{Ptr{Cvoid}}(Cx)
    isuniform = Ref{Bool}(false)
    libgb.GxB_Matrix_export_FullC(
        Ref(A.p),
        Ref(toGrB_Type(T).p),
        nrows,
        ncols,
        CRef,
        Csize,
        isuniform,
        desc
    )
    C = Matrix{T}(undef, nrows[], ncols[])
    unsafe_copyto!(pointer(C), Ptr{T}(CRef[]), length(C))
    return C
end

function toJL(A::GBMatrix)
    return exportdensematrix(A)
end


function exportdensevec(
    n::Integer, v::Vector{T};
    desc::Descriptor = Descriptors.NULL
) where {T}
    w = Ref{libgb.GrB_Vector}()
    n = libgb.GrB_Index(n)
    vsize = libgb.GrB_Index(sizeof(v))

    vx = Ptr{T}(Libc.malloc(vsize))
    unsafe_copyto!(vx, pointer(v), length(v))
    libgb.GxB_Vector_export_Full(
        w,
        toGrB_Type(T),
        n,
        Ref{Ptr{Cvoid}}(vx),
        vsize,
        false,
        desc
    )
    return GBVector{T}(w[])
end

function toGB(v::Vector)
    return exportdensevec(size(v)..., v)
end
