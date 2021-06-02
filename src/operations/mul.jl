function mul!(C::GBMatrix, A::GBMatrix, B::GBMatrix, semiring = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    if semiring === nothing
        if eltype(C) == Bool
            semiring = Semirings.LOR_LAND_SEMIRING[eltype(C)]
        else
            semiring = Semirings.PLUS_TIMES_SEMIRING[eltype(C)]
        end
    end
    libgb.GrB_mxm(C, mask, accum, semiring, A, B, desc)
end

function mul!(w::GBVector, u::GBVector, A::GBMatrix, semiring = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    if semiring === nothing
        if eltype(w) == Bool
            semiring = Semirings.LOR_LAND_SEMIRING[eltype(w)]
        else
            semiring = Semirings.PLUS_TIMES_SEMIRING[eltype(w)]
        end
    end
    libgb.GrB_vxm(w, mask, accum, semiring, u, A, desc)
end

function mul!(w::GBVector, A::GBMatrix, u::GBVector, semiring = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    if semiring === nothing
        if eltype(w) == Bool
            semiring = Semirings.LOR_LAND_SEMIRING[eltype(w)]
        else
            semiring = Semirings.PLUS_TIMES_SEMIRING[eltype(w)]
        end
    end
    libgb.GrB_mxv(w, mask, accum, semiring, A, u, desc)
end

function mul(A::GBVecOrMat, B::GBVecOrMat, semiring = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    semiring = findsemiring(A, semiring, B)
    t = juliatype(ztype(semiring))
    if A isa GBVector && B isa GBMatrix
        C = GBVector{t}(size(B, 2))
    elseif A isa GBMatrix && B isa GBVector
        C = GBVector{t}(size(A, 1))
    elseif A isa GBMatrix && B isa GBMatrix
        C = GBMatrix{t}(size(A, 1), size(B, 2))
    else
        throw(MethodError(mul, [GBVector, GBVector, typeof(semiring)]))
    end
    mul!(C, A, B, semiring; mask = mask, accum = accum, desc = desc)
    return C
end

function defaultsemiring(A::GBVecOrMat)
    if eltype(A) == Bool
        return Semirings.LOR_LAND_SEMIRING[eltype(A)]
    else
        return Semirings.PLUS_TIMES_SEMIRING[eltype(A)]
    end
end

function findsemiring(A, semiring = nothing, B = nothing)
    if B === nothing || eltype(A) == eltype(B)
        if semiring === nothing # No semiring provided, going with default semirings
            if eltype(A) == Bool
                return Semirings.LOR_LAND_SEMIRING[eltype(A)]
            elseif eltype(A) ∈ valid_vec
                return Semirings.PLUS_TIMES_SEMIRING[eltype(A)]
            else
                error("No default semiring found for this argument.")
            end
        else
            return semiring[eltype(A)]
        end
    elseif typeof(semiring) == libgb.GrB_Semiring
        return semiring
    else
        error("Semiring Not Found, if eltype(A) != eltype(B) you must specify a typed semiring")
    end
end
