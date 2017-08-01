"""
# Module *readfiles*

Retrieve folder paths and file names from script arguments. Issue warnings and abort,
if input files are not specified.

# Script Arguments
- `fkpp`: String with whitespace-separated list of kpp files from mechanims folder
  (without folder path and file endings;
  wrap in quotes or double quotes, when calling main script in shell)
- `fdat`: folder path + full file name for emissions/depositions data file
- `fout`: folder path + full file name of output file
  (optional; default: [emiss/depos]\_<data file name>.kpp)
- `flstd` (depositions only): flag to extend standard deposition value
  to all species in mechanism
  (0: defined values only; 1: use of vd(standard))

# Functions
- rdkpp
- rddat
- rdout
- rdstd
"""
module readfiles

export rdkpp, rddat, rdout, rdstd

"""
    rdkpp(ikpp,ini)

Read in string `ikpp` with list of whitespace-separated kpp files
from mechanisms folder (without folder paths and file endings) and
return array `fkpp` with strings of folder paths and full kpp file names.

Stop programme, when string is empty or files don't exist and issue warnings.
Additionally string `ini` (defined as `deposition` or `emission`) is used
to specify the screen output.
"""
function rdkpp(ikpp,ini)

  # Warn and quit, if no input kpp file is specified
  if ikpp == ""
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


"""
    rddat(fdat,ini)

Read in string `fdat` with data file folder path/file name and stop for
empty strings or missing files. Returns file name `fdat`.

Additionally string `ini` (defined as `deposition` or `emission`) is used
to specify the screen output.
"""
function rddat(fdat,ini)

  # Quit, if no emissions file is specified
  if fdat == ""
    print("\033[95m\nWarning! No $(ini)s file specified.\n")
    print("Generation of $ini scheme aborted.\033[0m\n")
    exit(91)
  end

  # Stop and warn for missing files
  if isfile(fdat) == false
    print("\033[95m\nWarning! $(titlecase(ini))s file '$(fdat)' doesn't exist.\n")
    print("Generation of $ini scheme aborted.\033[0m\n")
    exit(99)
  end

  # Print selected file to screen (omit standard InitCons folder in output)
  println("Data file:         $(replace(fdat,"./InitCons/",""))")
  return fdat

end #function rdkpp


"""
    rdout(fout,fdat,ini)

Read in string `fout` and `fdat` with output kpp and data file folder paths/file names,
respectively, and returns file name `fout`.

If `fout` is an empty string a standardised file name is used using the file name of `fdat`
and string `ini` (defined as `deposition` or `emission`):

    [emiss/depos]\_<data file name>.kpp
"""
function rdout(fout,fdat,ini)
  # If output kpp file name is not specified, retrieve input file name without file ending
  # and specify output file as "./mechanisms/emiss_<emi file>.kpp"
  if fout == ""
    fout = "./mechanisms/$(ini[1:5])_" *
           join(split(split(fdat,'/')[end],'.')[1:end-1],".") * ".kpp"
  end

  # Print selected file to screen (omit standard mechanisms folder in output)
  println("KPP output file:   $(replace(fout,"./mechanisms/",""))\033[0m\n")
  return fout

end #function rdout


"""
    rdstd(flstr)

Read in string `flstr` and return integer flag `flstd` to specify the use
of a standard deposition velocity.

If `flstr` is empty, define `flstd` as `1.`
"""
function rdstd(flstr)
  if flstr == ""
    flstd = 1
  else
    flstd = parse(Int64,flstr)
  end

  return flstd
end #function rdstd


end #module readfiles
