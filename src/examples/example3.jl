# Configuration for running spatial simulation
const simtype = 2    
const num_trials = 2
@everywhere const N_list = [8,16]        # Meta-population size list
const num_subpops_list = [4]                     # Number of subpopulations
const mu_list = [0.0]
const num_emigrants_list = [1]                    # number emigrants
const num_attributes_list = [1]        # number attributes 
const ngens = 10       # Generations after burn-in
const horiz_select_list=[true]
const linear_variation_list=[true]
const extreme_variation_list=[false]
const burn_in= 1.0    # generations of burn_in as a multiple of N
normal_stddev = 0.05
const use_fit_locations_list=[false]
const patchy_list=[false,true]
const fit_slope = 0.0
const additive_error = true
const neutral = false


