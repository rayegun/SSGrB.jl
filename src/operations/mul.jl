function mul!(C::GBMatrix, A::GBMatrix, B::GBMatrix, semiring = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    size(A, 2) == size(B, 1) || throw(DimensionMismatch())
    size(A, 1) == size(C, 1) || throw(DimensionMismatch())
    size(B, 2) == size(C, 2) || throw(DimensionMismatch())
    semiring = getsemiring(A, B, semiring)
    libgb.GrB_mxm(C, mask, accum, semiring, A, B, desc)
end

function mul!(w::GBVector, u::GBVector, A::GBMatrix, semiring = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    size(u) == size(A, 1) || throw(DimensionMismatch())
    size(w) == size(A, 2) || throw(DimensionMismatch())
    semiring = getsemiring(A, B, semiring)
    libgb.GrB_vxm(w, mask, accum, semiring, u, A, desc)
end

function mul!(w::GBVector, A::GBMatrix, u::GBVector, semiring = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    size(u) == size(A, 2) || throw(DimensionMismatch())
    size(w) == size(A, 1) || throw(DimensionMismatch())
    semiring = getsemiring(A, B, semiring)
    libgb.GrB_mxv(w, mask, accum, semiring, A, u, desc)
end

function mul(A::GBVecOrMat, B::GBVecOrMat, semiring = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    semiring = getsemiring(A, B, semiring)
    t = juliatype(ztype(semiring))
    if A isa GBVector && B isa GBMatrix
        C = GBVector{t}(size(B, 2))
    elseif A isa GBMatrix && B isa GBVector
        C = GBVector{t}(size(A, 1))
    elseif A isa GBMatrix && B isa GBMatrix
        C = GBMatrix{t}(size(A, 1), size(B, 2))
    end
    mul!(C, A, B, semiring; mask = mask, accum = accum, desc = desc)
    return C
end
