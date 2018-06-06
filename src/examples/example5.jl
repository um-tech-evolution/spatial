# Configuration for running spatial simulation
#=
Recommended command line to run:
>  julia run.jl examples/example5
or
>  julia -p 4 run.jl examples/example5
=#
const simtype = 2    
const num_trials = 1
@everywhere const N_list = [32]        # Meta-population size list
const num_subpops_list = [1,4,8,16]
const normal_stddev = 0.1
const mu_list = [0.05]                 # per-individual innovation rate 
const num_emigrants_list = [0]                    # number emigrants
const num_attributes_list = [1]        # number attributes 
const ngens = 5       # Generations after burn-in
const horiz_select_list=[false]
const linear_variation_list=[true]
const extreme_variation_list=[false]
const patchy_list=[true]
const burn_in= 0.1    # generations of burn_in as a multiple of N
const use_fit_locations_list=[true]
const fit_slope = 0.0
const additive_error = false
const neutral = false

