# Configuration for running spatial simulation
#=
Recommended command line to run:
>  julia -L SpatialEvolution.jl run.jl configs/example1
or
>  julia -p 4 -L SpatialEvolution.jl run.jl configs/example1
=#
export simtype
@everywhere simtype = 2    
const num_trials = 1
#@everywhere const N = 8        # Meta-population size
@everywhere const N_list = [8]        # Meta-population size list
const num_subpops_list = [2,4]                     # Number of subpopulations
const mu = 0.20                 # per-individual innovation rate 
#const num_emmigrants = 1                    # number emmigrants
const num_emmigrants_list=[1]
#const num_attributes = 2        # number attributes for quantitative representation
const num_attributes_list = [1]        # number attributes for quantitative representation
#const use_fit_locations=true
const use_fit_locations_list=[true]
#const horiz_select=false
const horiz_select_list=[false]
#const linear_variation=true
const linear_variation_list=[true]
#const extreme_variation=false
const extreme_variation_list=[false]
const ngens = 2       # Generations after burn-in
const burn_in= 3    # if integer, generations of burn in.  If float, generations of burn_in as a multiple of N
const normal_stddev = 0.04
#const patchy=false
const patchy_list=[true]
#const ideal_max = 1.0
#const ideal_min = 1.0
#const ideal_range = 0.0
const fit_slope = 1.0
const additive_error = false
const neutral = false
