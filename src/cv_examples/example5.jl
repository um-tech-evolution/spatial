# Configuration for running spatial simulation
export simtype
#global simtype=1 # means spatial structure by fitness or selection coefficient adjustment
# simtype=2 means spatial structure by changing the ideal values for attributes
@everywhere simtype = 2    
#@everywhere const N_list = [512,256,128,64,32,16,8,4,2]        # Meta-population size
#@everywhere const N_list = [128,64,32,16]        # Meta-population size
@everywhere const N_list = [16]        # Meta-population size
#mutation_stddev_list = [0.005,0.01, 0.02, 0.05,0.1]
#N_mut_list = [2.56,5.12,10.24,25.6,51.2]
N_mut_list = [51.2]
const num_subpops = 1                    # Number of subpopulations
const mu = 0.00                 # per-individual innovation rate.  Not used in cont_var
const ne = 0                    # number emmigrants
#const num_attributes_list = [1,5,10,50]        # number attributes for quantitative representation
const num_attributes_list = [1]        # number attributes for quantitative representation
const ngens = 200       # Generations after burn-in
const horiz_select=false
const circular_variation=false
const extreme_variation=false
const burn_in= 2.0    # generations of burn_in as a multiple of N
const num_fit_locations=1
const use_fit_locations=false
const ideal_max = 0.5
const ideal_min = 0.5
const ideal_range = 0.0


