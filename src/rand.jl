#This is a short-term solution. Options are replicating SparseArrays.sprand exactly
# or just import(sprand(...))
function sprand(
    r::AbstractRNG,
    m::Integer,
    n::Integer,
    density::AbstractFloat,
    rfn::Function,
    ::Type{T} = eltype(rfn(r, 1))
) where T
    m, n = Int(m), Int(n)
    (m <= 0 || n <= 0) && throw(ArgumentError("Invalid Array Dimensions"))
    0 <= density <= 1 || throw(ArgumentError("$density ∉ [0,1]"))
    I = randsubseq(r, 1:(m*n), density)
    Ix = similar(I)
    Jx = similar(I)
    for i ∈ 1:length(I)
        x, y = divrem(I[i], m)
        if y == 0
            Jx[i] = x
            Ix[i] = n
        else
            Jx[i] = x + 1
            Ix[i] = y
        end
    end
    print(I)
    print(Ix)
    print(Jx)
    return GBMatrix(Ix, Jx, rfn(r, length(I)); nrows = m, ncols = n)
end

function sprand(::Type{T}, m::Integer, n::Integer, density::AbstractFloat) where T
    sprand(default_rng(), m, n, density, (r, i) -> rand(r, T, i), T)
end
