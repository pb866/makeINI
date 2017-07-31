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

export rdkpp, rddat, rdout, rdstd

function rdkpp(ikpp,ini)
  if ikpp == ""
    # Quit, if no input kpp file is specified
    print("\033[95m\nWarning! No mechanism file(s) specified.\n")
    print("Generation of $ini scheme aborted.\033[0m\n")
    exit(90)
  end

  # Define folder path and full file names of input kpp file names
  fkpp = split(ikpp)
  for i in collect(1:length(fkpp)) fkpp[i] = "./mechanisms/"*fkpp[i]*".kpp" end

  # Loop over input files, stop and warn if non-existant
  # KPP files
  for f in fkpp
    if isfile(f) == false
      # Issue warnign, if a file doesn't exist and quit script
      print("\033[95m\nWarning! Mechanism file '$f' doesn't exist.\n")
      print("Generation of $ini scheme aborted.\033[0m\n")
      exit(97)
    end
  end

  # Print selected files to screen
  println("\n\033[94mMechanism file(s): $(replace(join(fkpp,", "),"./mechanisms/",""))")
  return fkpp

end #function rdkpp


function rddat(fdat,ini)

if fdat == ""
  # Quit, if no emissions file is specified
  print("\033[95m\nWarning! No $(ini)s file specified.\n")
  print("Generation of $ini scheme aborted.\033[0m\n")
  exit(91)
end
# Data file
  if isfile(fdat) == false
    print("\033[95m\nWarning! $(titlecase(ini))s file '$(fdat)' doesn't exist.\n")
    print("Generation of $ini scheme aborted.\033[0m\n")
    exit(99)
  end

  println("Data file:         $(replace(fdat,"./InitCons/",""))")
  return fdat

end #function rdkpp


function rdout(fout,fdat,ini)
  if fout == ""
    # If output kpp file name is not specified, retrieve input file name without file ending
    # and specify output file as "./mechanisms/emiss_<emi file>.kpp"
    fout = "./mechanisms/$(ini)_" *
           join(split(split(fdat,'/')[end],'.')[1:end-1],".") * ".kpp"
  end

  println("KPP output file:   $(replace(fout,"./mechanisms/",""))\033[0m\n")
  return fout

end #function rdout


function rdstd(flstr)
  if flstr == ""
    flstd = 1
  else
    flstd = parse(Int64,flstr)
  end

  return flstd
end #function rdstd


end #module readfiles
