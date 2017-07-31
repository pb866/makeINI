#!/usr/local/bin/julia

# Define path to add julia modules
# Save main script in /src/background and modules in /src/background/jl.mod
push!(LOAD_PATH,"$(pwd())/makeINI/jl.mod")
# push!(LOAD_PATH,"$(pwd())/src/background/jl.mod")
using DataFrames
using readfiles, rddata, wrtkpp

# prevent error messages from empty array by assuring at least 4 elements with empty strings
for i in range(1,4) push!(ARGS,"") end
# Retrieve folder paths and file names from script arguments
fkpp  = rdkpp(ARGS[1],"deposition")
fdat  = rddat(ARGS[2],"deposition")
fout  = rdout(ARGS[3],ARGS[2],"depos")
flstd = rdstd(ARGS[4])
# Read in emission data from input files defined in second script argument
depos = rdini(fdat)
# Retrieve all species (KPP names) from current mechanisms defined in first script argument
kppspc = rdspc(fkpp)
# Write emission scheme to output file
# (defined in 3rd argument, default: ./mechanisms/emiss_<data file name>.kpp)
# and print information to screen
depkpp(fout,fdat,depos,kppspc,flstd)
