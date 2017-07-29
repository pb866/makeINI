#!/usr/local/bin/julia

# ARGS = ["inorganic organic","../InitCons/Edw14.emi"]

# Set standard values for missing file names from programme arguments
push!(LOAD_PATH,"$(pwd())/jl.mod")
using DataFrames
using readfiles, rddat
# using test
#
# pstr(2.e-13,1.0)
# println(fkpp,fdat,fout)
emiss = rdini(fdat)
println("\n\n$emiss")
