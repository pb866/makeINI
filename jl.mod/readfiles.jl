"""
# Module *readfiles*

Retrieve folder paths and file names from script arguments. Issue warnings and abort,
if input files are not specified.

# Script Arguments
- fkpp: String with list of kpp files from mechanims folder
  (without folder path and file endings;
  wrap in quotes or double quotes, when calling main script in shell)
- fdat: folder path + full file name for emissions/depositions data file
- fout: folder path + full file name of output file
  (optional; default: [emiss/depos]\_<data file name>.kpp)
"""
module readfiles

export fkpp, fdat, fout

if length(ARGS) == 0
  # Quit, if no input kpp file is specified
  print("\033[95m\nWarning! No input kpp file(s) specified.\n")
  print("Generation of emission scheme aborted.\033[0m\n")
  exit(90)
elseif length(ARGS) == 1
  # Quit, if no emissions file is specified
  print("\033[95m\nWarning! No emissions file specified.\n")
  print("Generation of emission scheme aborted.\033[0m\n")
  exit(91)
elseif length(ARGS) == 2
  # If output kpp file name is not specified, retrieve input file name without file ending
  # and specify output file as "./mechanisms/emiss_<emi file>.kpp"
  fout = "./mechanisms/emiss_" *
         join(split(split(ARGS[2],'/')[end],'.')[1:end-1],".") * ".kpp"
else
  # Retrieve output kpp file name (if available)
  fout = ARGS[3]
end

# Define folder path and full file names of input kpp file names
fkpp = split(ARGS[1])
for i in collect(1:length(fkpp)) fkpp[i] = "./mechanisms/"*fkpp[i]*".kpp" end

# Loop over input files, stop and warn if non-existant
# KPP files
for f in fkpp
  if isfile(f) == false
    # Issue warnign, if a file doesn't exist and quit script
    print("\033[95m\nWarning! Mechanism file '$f' doesn't exist.\n")
    print("Generation of emission scheme aborted.\033[0m\n")
    exit(97)
  end
end
# Data file
fdat = ARGS[2]
if isfile(fdat) == false
  print("\033[95m\nWarning! Emissions file '$(fdat)' doesn't exist.\n")
  print("Generation of emission scheme aborted.\033[0m\n")
  exit(99)
end

# Print selected files to screen
println("\n\033[94mData file:          $(replace(fdat,"./InitCons/",""))")
println("KPP output file:    $(replace(fout,"./mechanisms/",""))")
println("Mechanisms file(s): $(replace(join(fkpp,", "),"./mechanisms/",""))\033[0m\n")


end #module readfiles
