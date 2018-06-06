# Configuration for running spatial simulation
# Configuration for effect of IG transmission
const simtype = 2    
const num_trials     = 1  # Number of trials
const N_list = [64]        # Meta-population size
const num_subpops_list = [32]                     # Number of subpopulations
const mu_list = [0.00]                 # per-individual innovation rate 
const copy_err_prob = 1.0       # per-individual copy error probability, not used quantitative
const num_emigrants_list = [0]                    # number emigrants
const num_attributes_list = [1]        # number attributes 
const ngens = 3          # Generations after burn-in
const horiz_select_list=[false]
const linear_variation_list=[true]
const extreme_variation_list=[false]
const burn_in= 2.0    # generations of burn_in as a multiple of N
const normal_stddev = 0.05
const use_fit_locations_list=[true]
const patchy_list=[false]
const fit_slope = 1.0
const additive_error = false
const neutral = false

