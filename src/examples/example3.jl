# Configuration for running spatial simulation
export simtype
#global simtype=1 # means spatial structure by fitness or selection coefficient adjustment
# simtype=2 means spatial structure by changing the ideal values for attributes
@everywhere simtype = 2    
const num_trials = 2
#@everywhere const N = 16        # Meta-population size
@everywhere const N_list = [8,16]        # Meta-population size list
#const num_subpops_list = [1,2,4,8,16,32]                     # Number of subpopulations
const num_subpops_list = [4]                     # Number of subpopulations
const mu = 0.00                 # per-individual innovation rate 
#const ne = 0                    # number emmigrants
const ne_list = [0]                    # number emmigrants
const num_attributes = 1        # number attributes for quantitative representation
const ngens = 10       # Generations after burn-in
#const horiz_select=true
const horiz_select_list=[true]
#const circular_variation=true
const circular_variation_list=[true]
#const extreme_variation=false
const extreme_variation_list=[false]
const burn_in= 1.0    # generations of burn_in as a multiple of N
normal_stddev = 0.05
const use_fit_locations_list=[false]
const ideal_max = 0.8
const ideal_min = 0.2
const ideal_range = 0.1
const fit_slope = 0.0
const additive_error = true
const neutral = false


