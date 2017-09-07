# Configuration for running spatial simulation
export simtype
#global simtype=1 # means spatial structure by fitness or selection coefficient adjustment
# simtype=2 means spatial structure by changing the ideal values for attributes
@everywhere simtype = 2    
@everywhere const N_list = [32,64]        # Meta-population size list
const num_attributes_list = [1,5]        # number attributes for quantitative representation
const N_mut_list = [0.5, 1.0, 2.0, 4.0]
const num_subpops = 1
const mu = 0.00                 # per-individual innovation rate.  Not used in cont_var
const ngens = 10000       # Generations after burn-in
const horiz_select=false
const burn_in= 2.0    # generations of burn_in as a multiple of N
const ideal = 0.5


