# Configuration for running spatial simulation
#=
Recommended command line to run:
>  julia -L ContVarEvolution.jl run_cv.jl cv_examples/example1
or
>  julia -p 4 -L ContVarEvolution.jl run_cv.jl cv_examples/example1
=#
export simtype
@everywhere simtype = 2    
#@everywhere const N = 8        # Meta-population size
@everywhere const N_list = [4]        # Meta-population size list
#const mutation_stddev = 0.05
#const num_attributes = 1        # number attributes for quantitative representation
#const num_attributes = 1        # number attributes for quantitative representation
const ngens = 2       # Generations after burn-in
const num_attributes_list = [1]        # number attributes for quantitative representation
const mutation_stddev_list = [0.05]
N_mut_list = [1.0]
const num_subpops = 1
const mu = 0.00                 # per-individual innovation rate.  Not used in cont_var.
const ne = 1                    # number emmigrants
const num_fit_locations=1
#const use_fit_locations=false
const horiz_select=false
const burn_in= 0.1    # generations of burn_in as a multiple of N
const ideal = 0.5
