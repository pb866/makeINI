#!/usr/local/bin/julia

# ARGS = ["inorganic organic","../InitCons/Edw14.emi"]

# Set standard values for missing file names from programme arguments
push!(LOAD_PATH,"$(pwd())/jl.mod")
using readfiles
