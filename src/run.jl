# Suggested command-line execution:  > julia run.jl configs/example1 1   # 1 is the random number seed
# Suggested command-line execution:  > julia -p 4 run.jl configs/example1 1  # 4 is the number of cores

@everywhere include("SpatialEvolution.jl")

@doc """ function save_params()
  Save the parameters specified in the configuration file into SpatialEvolution.spatial_result() data structure.
  The parameters are global variables.
"""
function save_params()
  global seed
  num_fit_locations = use_fit_locations_list[1] ? maximum(num_subpops_list) : num_subpops_list[1]
  # sim_record  is a record containing both the parameters and the results for a trial
  sim_record = SpatialEvolution.spatial_result( seed,
    num_trials, N_list, num_subpops_list, num_fit_locations, num_emigrants_list, num_attributes_list, mu_list, ngens,
    burn_in, use_fit_locations_list, horiz_select_list, linear_variation_list, extreme_variation_list, normal_stddev,
      fit_slope, additive_error, neutral )
  return sim_record
end


global seed = 1 # random number seed.  Note that runs using the "-p" option are not deterministic when run with the same seed.
println("run")
if length(ARGS) == 0
  simname = "configs/example2"
else
  simname = ARGS[1]
  if length(ARGS) >= 2   # second command-line argument is random number seed
    seed = parse(Int,ARGS[2])
    println("seed: ",seed)
  end
  srand(seed)
end
include("$(simname).jl")
println("simname: ",simname)
println("simtype: ",simtype)
sim_record = save_params()
run_trials( simname, sim_record )  # Writes the CSV file with one record per trail


