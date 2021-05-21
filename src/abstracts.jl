
abstract type Abstract_GrB_Struct end
abstract type Abstract_GrB_Op end
abstract type Abstract_GrB_UnaryOp <: Abstract_GrB_Op end
abstract type Abstract_GrB_BinaryOp <: Abstract_GrB_Op end
abstract type Abstract_GrB_SelectOp <: Abstract_GrB_Op end
abstract type Abstract_GrB_Monoid <: Abstract_GrB_Op end
abstract type Abstract_GrB_Semiring <: Abstract_GrB_Op end
abstract type Abstract_GrB_Type <: Abstract_GrB_Op end
#Base.unsafe_convert(s::Abstract_GrB_Struct) = getfield(s, :p)

isloaded(o::Abstract_GrB_Op) = !isempty(o.pointers)

function validtypes(o::Abstract_GrB_Op)
    isloaded(o) || load(o)
    return keys(o.pointers)
end

function Base.getindex(o::Abstract_GrB_Op, t::DataType)
    isloaded(o) || load(o)
    getindex(o.pointers, t)
end
