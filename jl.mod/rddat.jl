module rddat
using DataFrames
export rdini


function rdini(fdat::String)
  inidat = DataFrame(spc = String[], vd = String[])
  open(fdat,"r") do f
    flines = readlines(f)
    for line in flines
      data_lines = match(r"[^#]*", line)
      data_lines = split(data_lines.match)
      if isempty(data_lines) == false
        push!(inidat,data_lines)
      end
    end
  end
  return inidat
end #function inidat

end #module rddat
