try   # These are needed julia v7, but will fail in julia v6.  The try ... catch will recover from the failure
  using Distributed
  using Random
  using Dates
catch
end

@everywhere include("SpatialEvolution.jl")
#using SpatialEvolution
# Suggested command-line execution:  >  julia run.jl configs/example1
#=
function run_trials( simname::AbstractString ) 
  stream = open("$(simname).csv","w")
  println("stream: ",stream)
  num_fit_locations = use_fit_locations_list[1] ? maximum(num_subpops_list) : num_subpops_list[1]
  sr = SpatialEvolution.spatial_result(num_trials, N_list[1],num_subpops_list[1],num_fit_locations,num_emigrants_list[1],num_attributes_list[1], mu, ngens, burn_in,
      use_fit_locations_list[1], horiz_select_list[1], circular_variation_list[1], extreme_variation_list[1], normal_stddev, 
      patchy, ideal_max, ideal_min, ideal_range, fit_slope, additive_error, neutral )
  sr_list_run = SpatialEvolution.spatial_result_type[]
  trial=1
  for N in N_list
    for num_subpops in num_subpops_list
      for num_emigrants in num_emigrants_list
        for use_fit_locations in use_fit_locations_list
          for extreme_variation in extreme_variation_list
            for circular_variation in circular_variation_list
              if !(extreme_variation && circular_variation)   # extreme variation and circular variation are not compatible
                for horiz_select in horiz_select_list
                  num_fit_locations = use_fit_locations ? maximum(num_subpops_list) : num_subpops
                  for num_attributes in num_attributes_list
                    for trial = 1:num_trials
                      sr = SpatialEvolution.spatial_result(num_trials, N,num_subpops,num_fit_locations,num_emigrants,num_attributes, mu, ngens, burn_in,
                        use_fit_locations, horiz_select, circular_variation, extreme_variation, normal_stddev, 
                        patchy, ideal_max, ideal_min, ideal_range, fit_slope, additive_error, neutral )
                      println("num_subpops: ",sr.num_subpops,"  num_fit_locations: ",sr.num_fit_locations,"  num_attributes: ",sr.num_attributes  )
                      Base.push!(sr_list_run, sr )
                      #println("= = = = = = = =")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  println("===================================")
  sr_list_result = pmap(spatial_simulation, sr_list_run )
  trial = 1
  writeheader( stream, num_subpops_list, sr )
  writeheader( STDOUT, num_subpops_list, sr )
  for sr_result in sr_list_result
    writerow(stream,trial,sr_result)
    writerow(STDOUT,trial,sr_result)
    trial += 1
  end
end    
=#

@doc """ function save_params()
  Save the parameters specified in the configuration file into SpatialEvolution.spatial_result() data structure.
  The parameters are global variables.
"""
function save_params()
  num_fit_locations = use_fit_locations_list[1] ? maximum(num_subpops_list) : num_subpops_list[1]
  # sim_record  is a record containing both the parameters and the results for a trial
  sim_record = SpatialEvolution.spatial_result( 
    num_trials, N_list, num_subpops_list, num_fit_locations, num_emigrants_list, num_attributes_list, mu, ngens,
    burn_in, use_fit_locations_list, horiz_select_list, circular_variation_list, extreme_variation_list, normal_stddev,
      patchy, ideal_max, ideal_min, ideal_range, fit_slope, additive_error, neutral )
  return sim_record
end



if length(ARGS) == 0
  simname = "examples/example2"
else
  simname = ARGS[1]
  if length(ARGS) >= 2   # second command-line argument is random number seed
    seed = parse(Int,ARGS[2])
    println("seed: ",seed)
    srand(seed)
  end
end
include("$(simname).jl")
println("simname: ",simname)
println("simtype: ",simtype)
sim_record = save_params()
run_trials( simname, sim_record )
