# Configuration for running spatial simulation
#=
Recommended command line to run:
>  julia -L SpatialEvolution.jl run.jl configs/example2
or
>  julia -p 4 -L SpatialEvolution.jl run.jl configs/example2
=#
export simtype
#global simtype=1 # means spatial structure by fitness or selection coefficient adjustment
# simtype=2 means spatial structure by changing the ideal values for attributes
@everywhere simtype = 2    
#const vtbl = Dict{Int64,variant_type}()
const num_trials = 2
#@everywhere const N = 8        # Meta-population size
@everywhere const N_list = [8]        # Meta-population size list
const num_subpops_list = [1,2]
const normal_stddev = 0.1
const mu = 0.05                 # per-individual innovation rate 
#const num_emmigrants = 0                    # number emmigrants
const num_emmigrants_list = [0,2]                    # number emmigrants
#const num_attributes = 2        # number attributes for quantitative representation
const num_attributes_list = [2]        # number attributes for quantitative representation
const ngens = 5       # Generations after burn-in
#const use_fit_locations=false
#const horiz_select=true
const horiz_select_list=[false]
#const linear_variation=true
const linear_variation_list=[true]
#const extreme_variation=false
const extreme_variation_list=[false]
const patchy_list=[true]
const burn_in= 0.1    # generations of burn_in as a multiple of N
const use_fit_locations_list=[true]
const fit_slope = 0.0
const additive_error = false
const neutral = false

