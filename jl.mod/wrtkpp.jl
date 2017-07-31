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
- emikpp
- print_scrn (internal)
- write_kpp (internal)
"""
module wrtkpp
using DataFrames
export emikpp, depkpp


"""
    emikpp(fout,emiss,kppspc)

Write emission data (in emiss) to output file (fout), if species is part of the current
mechanism (species exists in kppspc).
"""
function emikpp(fout,emiss,kppspc)
  # Find common species of emission data and current mechanism
  emiidx = findin(emiss[:spc],kppspc)
  emispc = DataFrame(spc = String[], rate = String[])
  emispc = emiss[emiidx,:]
  # Write mechanism to kpp file and print screen info
  write_emi(fout,emispc)
  print_scrn(emispc, "emission", length(emiss[1])-length(emispc[1]), 0, 0)
end #function emikpp


"""
    depkpp(fout,fdat,depos,kppspc,flstd)

Write emission data (in emiss) to output file (fout), if species is part of the current
mechanism (species exists in kppspc).
"""
function depkpp(fout,fdat,depos,kppspc,flstd)
  # Find common species of emission data and current mechanism
  depidx = findin(depos[:spc],kppspc)
  depspc = DataFrame(spc = String[], dep = String[])
  depspc = depos[depidx,:]
  depmech, vdstd = defvd(flstd, depspc, depos, kppspc, fdat)

  # Write mechanism to kpp file and print screen info
  write_dep(fout,depmech)
  print_scrn(depspc, "deposition", length(depos[1])-length(depspc[1]), flstd, vdstd)
end #function depkpp


"""
    print_scrn(inispc,warn)

Print emissions used in current scenario (with species/emissions saved in inispc)
to screen and warn about omitted species in the emission data (saved in warn).
"""
function print_scrn(inispc,ini,warn,flstd,vdstd)

# Add warning if number of species in the original emission data differs
# from number of emissions used (info handed over in warn)
  if warn != 0
    println("\033[95mWarning! $(abs(warn)) species ignored\n"*
            "as they are not part of the current mechanism.\033[0m\n")
  end

# Print emission data of current scenario to screen
  println("\033[92mThe following $(ini)s are used in the current scenario:\033[0m")

  # Find longest species name for output formatting
  strmax = 0
  for str in inispc[:spc] if length(str) > strmax strmax = length(str) end end
  # Loop over species and print data to screen
  for i in collect(1:length(inispc[:spc]))
    align = ""; for j in collect(length(inispc[i,:spc]):strmax) align *= " " end
    @printf "%s%s%s\n" "$(inispc[i,:spc]):" align inispc[i,:rate]
  end

  if flstd == 1
  println("\033[92m----------------------------")
  println("\e[1mvd(standard): $vdstd")
  println("----------------------------\033[0m\n")
  end

end #function print_scrn


"""
    write_kpp(fout,emispc)

Write emissions data of current scenario (with species/emissions saved in emispc)
to the defined output kpp file (fout).
"""
function write_emi(fout,emispc)
  # Open write file
  open(fout,"w+") do f
    # Print header including information about applied script and date/time
    println(f,"//Generated by makeEMISS.jl (version 2.0) on $(Date(now())), $(Dates.Time(now()))")
    println(f,"//For updates, see https://github.com/pb866/makeINI")
    println(f,"#EQUATIONS")
    # Loop over species and write kpp code
    for (i,spc) in enumerate(emispc[:spc])
      println(f,"{E$i}  EMISS = $spc :  $(emispc[i,:rate]) ;")
    end
  end
end #function write_kpp


"""
    write_kpp(fout,depmech)

Write emissions data of current scenario (with species/emissions saved in emispc)
to the defined output kpp file (fout).
"""
function write_dep(fout,depmech)
  # Open write file
  open(fout,"w+") do f
    # Print header including information about applied script and date/time
    println(f,"//Generated by makeDEPOS.jl (version 2.0) on $(Date(now())), $(Dates.Time(now()))")
    println(f,"//For updates, see https://github.com/pb866/makeINI")
    println(f,"#EQUATIONS")
    # Loop over species and write kpp code
    for (i,spc) in enumerate(depmech[:spc])
      println(f,"{D$i}  $spc = DUMMY :  DEPOS*($(depmech[i,:rate])) ;")
    end
  end
end #function write_kpp


function defvd(flstd, depspc, depos, kppspc, fdat)

  vdidx = findin(depos[:spc],["DEPOS"])
  if isempty(vdidx)
    vdstd = "5.00d-6"
  else
    vdidx = vdidx[end]
    vdstd = depos[vdidx,:rate]
  end
  if flstd == 0
    depmech = depspc
    # On-screen information
    println("\033[94mOnly deposition data from $fdat used.")
    println("No use of a standard depositon rate.\033[0m\n")
  elseif flstd == 1
    depmech = DataFrame(spc = String[], rate = String[])
    for spec in kppspc push!(depmech, @data([spec, vdstd])) end
    for i in collect(1:length(depspc[:spc]))
      depidx = findin(depmech[:spc], [depspc[i,:spc]])[1]
      depmech[depidx,:rate] = depspc[i,:rate]
    end
    # On-screen information
    println("\033[94mStandard deposition rate extended to all species in mechanism.\033[0m\n")
  end

  return depmech, vdstd
end #function defvd

end #module rddat
