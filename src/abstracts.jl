
abstract type Abstract_GrB_Struct end
abstract type Abstract_GrB_Container end
abstract type Abstract_GrB_UnaryOp <: Abstract_GrB_Struct end
abstract type Abstract_GrB_BinaryOp <: Abstract_GrB_Struct end
abstract type Abstract_GrB_SelectOp <: Abstract_GrB_Struct end
abstract type Abstract_GrB_Monoid <: Abstract_GrB_Struct end
abstract type Abstract_GrB_Semiring <: Abstract_GrB_Struct end
abstract type Abstract_GrB_Type <: Abstract_GrB_Struct end
Base.unsafe_convert(s::Abstract_GrB_Struct) = getfield(s, :p)