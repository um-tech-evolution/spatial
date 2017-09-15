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
@everywhere const N_list = [25,50,100,200]        # Meta-population size list
const num_attributes_list = [1,5]        # number attributes for quantitative representation
const N_mut_list = [0.5, 1.0, 2.0, 4.0]
const num_subpops = 1
const ngens = 2       # Generations after burn-in
const burn_in= 0.1    # generations of burn_in as a multiple of N
const ideal = 0.5
const wrap_attributes=true # wrap attribute values to stay within the interval [0,1]
const additive_error=true  # use additive error when mutating attributes as opposed to mulitiplicative error
