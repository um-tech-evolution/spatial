# Configuration for running spatial simulation
#=
Recommended command line to run:
>  julia -L SpatialEvolution.jl run.jl examples/example1
or
>  julia -p 4 -L SpatialEvolution.jl run.jl examples/example1
=#
const simtype = 2    
const num_trials = 1
const N_list = [8]        # Meta-population size list
const num_subpops_list = [2,4]                     # Number of subpopulations
const mu_list = [0.2]
const num_emigrants_list=[1]
const num_attributes_list = [1]        # number attributes 
const use_fit_locations_list=[false]
const horiz_select_list=[false]
const linear_variation_list=[false,true]
const extreme_variation_list=[false,true]
const ngens = 2       # Generations after burn-in
const burn_in= 3    # if integer, generations of burn in.  If float, generations of burn_in as a multiple of N
const normal_stddev = 0.04
const fit_slope = 1.0
const additive_error = false
const neutral = false
