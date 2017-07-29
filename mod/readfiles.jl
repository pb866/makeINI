module readfiles

export fout, fkpp, fdat

  if length(ARGS) <= 1
    # Quit, if no emissions file is specified
    print("\033[95m\nWarning! No emissions file specified.\n")
    print("Generation of emission scheme aborted.\033[0m\n")
    quit()
  elseif length(ARGS) == 2
    # If output kpp file name is not specified, retrieve input file name without file ending
    # and specify output file as "./mechanisms/emiss_<emi file>.kpp"
    fout = "./mechanisms/emiss_" *
           join(split(split(ARGS[2],'/')[end],'.')[1:end-1],".") * ".kpp"
  else
    # Retrieve output kpp file name (if available)
    fout = ARGS[3]
  end

  # Stop, if input file doesn't exist
  fdat = ARGS[2]
  if isfile(fdat) == false
    print("\033[95m\nWarning! Emissions file doesn't exist.\n")
    print("Generation of emission scheme aborted.\033[0m\n")
    quit()
  end

  # Define full input kpp file names
  fkpp = split(ARGS[1])
  for i in collect(1:length(fkpp)) fkpp[i] = "./mechanisms/"*fkpp[i]*".kpp" end

  # Print selected files to screen
  println("\n\033[94mData file:          $(fdat)")
  println("KPP output file:    $(fout)")
  println("Mechanisms file(s): $(replace(join(fkpp,", "),"./mechanisms/",""))\033[0m\n")
end
