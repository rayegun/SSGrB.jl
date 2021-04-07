# SSGrB
Wrapper for Tim Davis' SuiteSparse:GraphBLAS. Originally forked from [SuiteSparseGraphBLAS.jl](https://github.com/abhinavmehndiratta/SuiteSparseGraphBLAS.jl) by Abhinav Mehndiratta. Significant inspiration was taken from that repository and its forks, but most code is being rewritten.

## TODO:
- [x] Each built-in semiring/binary op/unary op/monoid should have its own type for dispatch purposes.
- [x] Context and Sequence
    - [ ] GrB_error
- [ ] Object Construction and Methods 
- [ ] Select Op 
- [ ] Monoid 
- [ ] Semiring 
- [ ] Scalar and Vector 
- [ ] Matrix 
- [ ] Descriptors
- [ ] Operations
    - [ ] GrB_mxm, vxm, mxv
    - [ ] eWise
    - [ ] extract
    - [ ] assign/subassign
    - [ ] apply
    - [ ] select
    - [ ] reduce
    - [ ] others
- [ ] Import & Export
- [ ] User Defined Types
- [ ] Prep for CUDA Support