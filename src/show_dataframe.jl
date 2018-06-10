#! /usr/local/julia/bin/julia
# Julia program to show a CSV file as a Julia dataframe as text.
using DataFrames
import CSV.read


@doc """ read_dataframe( filename::String )
  Read a DataFrame from filename where there may be comment lines starting with hash characters preceding the
     header row and the data
"""
function read_dataframe( filename::String )
  line_number = 0
  open(filename) do f
    while true  # skip over comment lines that begin with a hash symbol
      line_number += 1
      line = strip(readline(f))
      if length(line) == 0 || line[1] != '#'
        break
      end
    end
  end
  # line_number is now the line number of the first non-comment line
  open(filename) do f
    for i = 1:(line_number-1)    # skip over comment lines
      readline(f)
    end
    return( CSV.read( f ) )
  end
end

if length(ARGS) == 0
  simname = "examples/example1"
else
  simname = ARGS[1]
end
println("simname: ",simname)
df = read_dataframe("$(simname).csv")
println("df: ",df)
