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
#const normal_stddev = 0.05
#const num_attributes = 1        # number attributes for quantitative representation
const num_attributes_list = [1,5]        # number attributes for quantitative representation
const normal_stddev_list = [0.05]
const num_subpops = 1
const mu = 0.00                 # per-individual innovation rate.  Not used in cont_var.
const ne = 1                    # number emmigrants
const num_attributes = 1        # number attributes for quantitative representation
const num_fit_locations=1
const use_fit_locations=true
const horiz_select=false
const circular_variation=false
const extreme_variation=true
const ngens = 2       # Generations after burn-in
const burn_in= 0.1    # generations of burn_in as a multiple of N
const ideal_max = 0.5
const ideal_min = 0.5
const ideal_range = 0.0
