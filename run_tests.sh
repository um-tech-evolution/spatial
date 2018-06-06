# Shows how to run based on an example configuration file  examples/example1.jl.
# The run will create  examples/example1.csv  as the output file.
# 
cd src

julia run.jl examples/example1 1
julia run.jl examples/example2 1
julia run.jl examples/example3 1
julia run.jl examples/example4 1

cd ..
