#!/usr/local/bin/julia

# Define path to add julia modules
# Save main script in /src/background and modules in /src/background/jl.mod
push!(LOAD_PATH,"$(dirname(Base.source_path()))/jl.mod")

# Load modules
using DataFrames
using readfiles, rddata, wrtkpp

# Define current purpose of ini script:
ini = "emission"

# prevent error messages from empty array by assuring at least 3 elements with empty strings
for i in range(1,3-length(ARGS)) push!(ARGS,"") end
# Retrieve folder paths and file names from script arguments
fkpp = rdkpp(ARGS[1],"emission")
fdat = rddat(ARGS[2],"emission")
fout = rdout(ARGS[3],ARGS[2],"emiss")
# Read in emission data from input files defined in second script argument
emiss = rdini(fdat)
# Retrieve all species (KPP names) from current mechanisms defined in first script argument
kppspc = rdspc(fkpp)
# Write emission scheme to output file
# (defined in 3rd argument, default: ./mechanisms/emiss_<data file name>.kpp)
# and print information to screen
wrtmech(fout,fdat,emiss,"emission",kppspc,0)
