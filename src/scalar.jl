struct GBScalar{T}
    p::libgb.GxB_Scalar
end

function GBScalar(v)
    x = GBScalar
end

Base.copy(x::GBScalar{T}) where {T} = GBScalar{T}(x.p)
Base.deepcopy(x::GBScalar{T})