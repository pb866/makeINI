__precompile__()
"""
# Module *wrtkpp*

Holds functions to write kpp code for initialisation data from data text files.

# Structure of input files
```shell
# Line comment: separation by whitespaces
# <KPP species name>  <vd / emission rate>
DEPOS     5.00d-6 #Inline comment: Use 'DEPOS' to override standard vd
CH3OH     1.00d-5
```

# Functions
- wrtmech
- print_scrn (internal)
- write_kpp (internal)
- defvd (internal)
"""
module wrtkpp
using DataFrames
export wrtmech


"""
    wrtmech(fout,fdat,inidat,inistr,kppspc,flstd)

Write emission/deposition data to output file and report on-screen.

# Arguments
- `fout`: Output file folder path and file name
- `fdat`: Data file folder path and file name
- `inidat`: Data frame with species names and emission or deposition rates
- `inistr`: Keyword `emission` or `deposition` based on current purpose/scenario
- `kppspc`: List of KPP names of all species of the current scenario
- `flstd`: Flag to extend standard deposition rate to all species in the
  current scenario
"""
function wrtmech(fout,fdat,inidat,inistr,kppspc,flstd)

  # Find common species in emission data definitions and the current mechanism
  # and save to inispc together with rates
  iniidx = findin(inidat[:spc],kppspc)
  inispc = DataFrame(spc = String[], rate = String[])
  inispc = inidat[iniidx,:]

  # Define species for output emission/depositon scheme based on mechanism
  # and flag for use of standard deposition
  if inistr == "deposition"
    inimech, vdstd = defvd(flstd, inispc, inidat, kppspc, fdat)
  elseif inistr == "emission"
    inimech = deepcopy(inispc)
    vdstd = 0.
  end
  # Leave only species in inidat (with original emission/depositon definitions),
  # where no common species in the data file and the current mechanism files could be found
  deleterows!(inidat,iniidx); deleterows!(inidat,findin(inidat[:spc],["DEPOS"]))

  # Write mechanism to kpp file and print screen info
  write_kpp(fout,inimech,inistr)
  print_scrn(inispc, inistr, inidat[:spc], flstd, vdstd)
end #function depkpp


"""
    print_scrn(inispc,inistr,errspc,flstd,vdstd)

Print emissions/depositions used in current scenario to screen and
warn about omitted species.

# Arguments
- `inispc`: Data frame with species names and emission/deposition rates
  to be used in current scenario
- `inistr`: String `emission` or `deposition` used define current purpose
  in on-screen messages
- `errspc`: Array with species names that have been omitted in the output
  as they were defined only in the data file, but not in the current mechanism
- `flstd`: Flag to signal the extension of a standard deposition rate
  to all species in the mechanism
- `vdstd`: Value of the standard deposition rate
"""
function print_scrn(inispc,inistr,errspc,flstd,vdstd)

  # Add warning if number of species in the original emission/deposition data differs
  # from number of emissions/depositions actually used
  if length(errspc) > 0
    println("\033[95mWarning! $(length(errspc)) species not part of the current mechanism ignored:")
    # Loop over omitted species and format a line break after every 8 species
    for i in eachindex(errspc[1:end-1])
      print("$(errspc[i]), ")
      if mod(i,8) == 0 print("\n") end
    end
    println("and $(errspc[end])\033[0m\n") # add and before last species and finish with line break
  end

  # Print emission data of current scenario to screen
  println("\033[92mThe following $(inistr)s are used in the current scenario:\033[0m")

  # Find longest species name for output formatting
  strmax = 0
  for str in inispc[:spc] if length(str) > strmax strmax = length(str) end end
  # Loop over species and print data to screen
  for i in collect(1:length(inispc[:spc]))
    align = ""; for j in collect(length(inispc[i,:spc]):strmax) align *= " " end
    @printf "%s%s%s\n" "$(inispc[i,:spc]):" align inispc[i,:rate]
  end

# if used, print standard deposition velocity
  if flstd == 1
  println("\033[92m\e[1m---------------------")
  println("vd(standard): $vdstd")
  println("---------------------\033[0m\n")
  end

end #function print_scrn


"""
    write_kpp(fout,inimech,inistr)

Write emissions/depositions (use defined by String `inistr`) data of current scenario
(with species/rates saved in `inimech`) to the defined output kpp file (`fout`).
"""
function write_kpp(fout,inimech,inistr)
  # Open write file
  open(fout,"w+") do f
    # Print header including information about applied script and date/time
    print(f,"//Generated by make$(uppercase(inistr[1:5])).jl (version 2.0) ")
    println(f,"on $(Date(now())), $(Dates.Time(now()))")
    println(f,"//For updates, see https://github.com/pb866/makeINI")
    println(f,"#EQUATIONS")
    # Loop over species and write kpp code
    for (i,spc) in enumerate(inimech[:spc])
      if inistr == "emission"
        println(f,"{E$i}  EMISS = $spc :  $(inimech[i,:rate]) ;")
      elseif inistr == "deposition"
        println(f,"{D$i}  $spc = DUMMY :  DEPOS*($(inimech[i,:rate])) ;")
      end
    end
  end
end #function write_kpp


"""
    defvd(flstd, depspc, depos, kppspc, fdat)

Define and return a standard deposition rate `vdstd`, if `flstd` is set to `1`.
Define and return the data frame `depmech` with species names and deposition rates
from `depspc` supplemented by the species in `kppspc` with the standard deposition rate.

If `flstd` is `0`, `depmech` consists only of the species in `depspc`.
Search in `depos` for the standard deposition rate, if obsolete, define
a value of 5.00d-6.
"""
function defvd(flstd, depspc, depos, kppspc, fdat)

  # Search for keyword 'DEPOS' in original array of depositon rates
  vdidx = findin(depos[:spc],["DEPOS"])
  if isempty(vdidx)
    # Assign a standard deposition value, if not otherwise pre-defined
    vdstd = "5.00d-6"
  else
    # Retrieve pre-defined standard depositon rate
    # (last value in case of multiple definitions)
    vdidx = vdidx[end]
    vdstd = depos[vdidx,:rate]
  end
  if flstd == 0
    # Use only common species of data file and mechanism files, if flstd is 0
    depmech = deepcopy(depspc)
    # On-screen information
    println("\033[94mOnly deposition data from $fdat used.")
    println("No use of a standard depositon rate.\033[0m\n")
  elseif flstd == 1
    # Define data frame with all species of current mechanism and assign
    # standard deposition rate if flstd = 1
    depmech = DataFrame(spc = String[], rate = String[])
    for spec in kppspc push!(depmech, @data([spec, vdstd])) end
    # Override standard rates, with pre-defined deposition values
    for i in collect(1:length(depspc[:spc]))
      depidx = findin(depmech[:spc], [depspc[i,:spc]])[1]
      depmech[depidx,:rate] = depspc[i,:rate]
    end
    # On-screen information
    println("\033[94mStandard deposition rate extended to all species in mechanism.\033[0m\n")
  end

  # Return array with species names and deposition rates and the standard deposition value
  return depmech, vdstd
end #function defvd

end #module rddat
