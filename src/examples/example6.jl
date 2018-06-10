# Configuration for running spatial simulation
const simtype = 2    
const num_trials = 10  # Number of trials
const N_list = [32]        # Meta-population size
const num_subpops_list = [16]                     # Number of subpopulations
const mu_list = [0.00,0.05]                 # per-individual innovation rate 
const copy_err_prob = 1.0       # per-individual copy error probability, not used quantitative
const num_emigrants_list = [0]                    # number emigrants
const num_attributes_list = [1]        # number attributes 
const ngens = 100          # Generations after burn-in
const horiz_select_list=[false]
const linear_variation_list=[true,false]
const extreme_variation_list=[true,false]
const burn_in= 2.0    # generations of burn_in as a multiple of N
normal_stddev = 0.05
const use_fit_locations_list=[true]
const patchy_list=[true]
const fit_slope = 1.0
const additive_error = false
neutral = false

