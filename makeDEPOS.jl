#!/usr/local/bin/julia

# Define path to add julia modules
# Save main script in /src/background and modules in /src/background/jl.mod
push!(LOAD_PATH,"$(dirname(Base.source_path()))/jl.mod")

# Load modules
using DataFrames
using readfiles, rddata, wrtkpp

# Define current purpose of ini script:
ini = "deposition"

# prevent error messages from empty array by assuring at least 4 elements with empty strings
for i in range(1,4-length(ARGS)) push!(ARGS,"") end
# Retrieve folder paths and file names from script arguments
fkpp  = rdkpp(ARGS[1],ini)
fdat  = rddat(ARGS[2],ini)
fout  = rdout(ARGS[3],ARGS[2],ini)
flstd = rdstd(ARGS[4])
# Read in emission data from input files defined in second script argument
depos = rdini(fdat)
# Retrieve all species (KPP names) from current mechanisms defined in first script argument
kppspc = rdspc(fkpp)
# Write emission scheme to output file
# (defined in 3rd argument, default: ./mechanisms/emiss_<data file name>.kpp)
# and print information to screen
wrtmech(fout,fdat,depos,ini,kppspc,flstd)
