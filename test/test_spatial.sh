# Shows how to run based on an example configuration file  configs/example1.jl.
# The run will create  configs/example1.csv  as the output file.
# 
cd ../src

julia -L SpatialEvolution.jl run.jl configs/example1
