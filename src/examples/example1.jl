# Configuration for running spatial simulation
#=
Recommended command line to run:
>  julia -L SpatialEvolution.jl run.jl configs/example1
or
>  julia -p 4 -L SpatialEvolution.jl run.jl configs/example1
=#
export simtype
@everywhere simtype = 2    
const num_trials = 2
#@everywhere const N = 8        # Meta-population size
@everywhere const N_list = [3]        # Meta-population size list
const num_subpops_list = [1]                     # Number of subpopulations
const mu = 0.00                 # per-individual innovation rate 
#const ne = 1                    # number emmigrants
const ne_list=[0]
const num_attributes = 2        # number attributes for quantitative representation
#const use_fit_locations=true
const use_fit_locations_list=[false]
#const horiz_select=false
const horiz_select_list=[false]
#const circular_variation=false
const circular_variation_list=[true]
#const extreme_variation=false
const extreme_variation_list=[false]
const ngens = 3       # Generations after burn-in
const burn_in= 3    # if integer, generations of burn in.  If float, generations of burn_in as a multiple of N
const normal_stddev = 0.04
const ideal_max = 1.0
const ideal_min = 1.0
const ideal_range = 0.0
const fit_slope = 1.0
const additive_error = false
const neutral = false
