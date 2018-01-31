# Shows how to run based on an example configuration file  examples/example1.jl.
# The run will create  examples/example1.csv  as the output file.
# 
cd src

julia -L SpatialEvolution.jl run.jl examples/example1
julia -L SpatialEvolution.jl run.jl examples/example2
julia -L SpatialEvolution.jl run.jl examples/example3
julia -L SpatialEvolution.jl run.jl examples/example4

cd ..
