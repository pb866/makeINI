__precompile__()
"""
# Module *rddata*

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
module rddata
using DataFrames
export rdini, rdspc


"""
    rdini(fdat)

Read emission/deposition data from input data file (`fdat` defined as String) and
return dataframe holding species names (`:spc`) and rates (`:rate`)
"""
function rdini(fdat::String)

  #Initialise dataframe
  inidat = DataFrame(spc = String[], rate = String[])
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
  # return emission/deposition data
  return inidat
end #function inidat


"""
    rdspc(fkpp)

Find all species in current mechanism from all input kpp files (`fkpp`)
and return list with species names (`kppspc`).
"""
function rdspc(fkpp)
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
          # After last species definition, exit current kpp file
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
