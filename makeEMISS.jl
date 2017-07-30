#!/usr/local/bin/julia

# Define path to add julia modules
# Save main script in /src/background and modules in /src/background/jl.mod
push!(LOAD_PATH,"$(pwd())/src/background/jl.mod")
using DataFrames
using readfiles, rddat, wrtkpp

# Read in emission data from input files defined in second script argument
emiss = rddat.rdini(fdat)
# Retrieve all species (KPP names) from current mechanisms defined in first script argument
kppspc = rdspc(fkpp)
# Write emission scheme to output file
# (defined in 3rd argument, default: ./mechanisms/emiss_<data file name>.kpp)
# and print information to screen
emikpp(fout,emiss,kppspc)
