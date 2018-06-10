# Shows how to run based on an example configuration file  examples/example1.jl.
# Each run will create a .csv output file:  e. g.  examples/example1.csv 
# These runs use random number seed 1.
# Use the "-p" option to speed up by using multiple cores: then using the same seed does not produce identical results.
# Example:  julia -p 4 run.jl examples/example1
# 
cd src

julia run.jl examples/example1 1
julia run.jl examples/example2 1
julia run.jl examples/example3 1
julia run.jl examples/example4 1
julia run.jl examples/example5 1
julia run.jl examples/example6 1
julia average_over_trials.jl examples/example1
julia average_over_trials.jl examples/example2

cd ..
