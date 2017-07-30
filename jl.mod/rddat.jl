__precompile__()
"""
# Module *rddat*

Holds functions for reading the data from all input files.

# Input files
- data file (path + file name; see structure below)
- all KPP files of current mechanism from mechanisms folder
  (no folder path or file ending specified, given as list separated by space, e.g.,
  `"file1 file2"`)

# Structure of data files
```shell
# Line comment: separation by whitespaces
# <KPP species name>  <vd / emission rate>
DEPOS     5.00d-6 #Inline comment: Use 'DEPOS' to override standard vd
CH3OH     1.00d-5
```

# Functions
- rdini
- rdspc
"""
module rddat
using DataFrames
export rdini, rdspc


"""
    rdini(fdat)

Read emission data from input data file (fdat defined as String) and
return dataframe holding species names (`:spc`) and emission rates (`:emi`)
"""
function rdini(fdat::String)

  #Initialise dataframe
  inidat = DataFrame(spc = String[], emi = String[])
  open(fdat,"r") do f
    # Read input data file
    flines = readlines(f)
    for line in flines
      # Filter comments and split into columns
      data_lines = match(r"[^#]*", line)
      data_lines = split(data_lines.match)
      # Write data to dataframe
      if isempty(data_lines) == false
        push!(inidat,data_lines)
      end
    end
  end
  # return emission data
  return inidat
end #function inidat


"""
    rdspc(fkpp)

Read emission data from all input kpp file(fkpp)
and return list with species names of current mechanism.
"""
function rdspc(fkpp::String)

  # Initialise list of kpp species
  kppspc = []
  # Loop over kpp files
  for file in fkpp
    spcdef = false # set flag for species definitions to an initial false
    open(file) do f
      # Read each kpp file
      lines = readlines(f)
      for line in lines
        if line == "#DEFVAR"
          # Set flag for species definitions to true upon keyword '#DEFVAR'
          spcdef = true
        elseif contains(uppercase(line),"IGNORE") == false && spcdef == true
          # Set flag for species definitions to false after last species definition
          break
        elseif line[1:2] == "//"
          # Ignore kpp comment lines
          continue
        elseif spcdef == true
          # In species definions: delete " = IGNORE ;" and save species to list
          push!(kppspc, replace(uppercase(line),r"[ \t]*=[ \t]*IGNORE[ \t]*;",""))
        end
      end
    end
  end
  # Return full list of species of current mechanism
  # (from all kpp files in kpp names)
  return kppspc
end #function rdspc

end #module rddat
