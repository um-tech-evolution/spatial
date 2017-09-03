# Configuration for running spatial simulation
export simtype
#global simtype=1 # means spatial structure by fitness or selection coefficient adjustment
# simtype=2 means spatial structure by changing the ideal values for attributes
@everywhere simtype = 2    
@everywhere const N_list = [32,64]        # Meta-population size list
const num_attributes_list = [1,5]        # number attributes for quantitative representation
mutation_stddev_list = [0.01,0.02,0.05]
const num_subpops = 1
const mu = 0.00                 # per-individual innovation rate.  Not used in cont_var
const ne = 0                    # number emmigrants
const ngens = 10000       # Generations after burn-in
const horiz_select=false
const circular_variation=false
const extreme_variation=false
const burn_in= 2.0    # generations of burn_in as a multiple of N
const num_fit_locations=1
const use_fit_locations=false
const ideal_max = 0.5
const ideal_min = 0.5
const ideal_range = 0.0


