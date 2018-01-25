using SpatialEvolution
# Suggested command-line execution:  >  julia -L SpatialEvolution.jl run.jl configs/example1

function run_trials( simname::AbstractString ) 
  stream = open("$(simname).csv","w")
  println("stream: ",stream)
  num_fit_locations = use_fit_locations_list[1] ? maximum(num_subpops_list) : num_subpops_list[1]
  sr = SpatialEvolution.spatial_result(N_list[1],num_subpops_list[1],num_fit_locations,ne_list[1],num_attributes, mu, ngens, burn_in,
      use_fit_locations_list[1], horiz_select_list[1], circular_variation, extreme_variation_list[1], normal_stddev, 
      ideal_max, ideal_min, ideal_range, fit_slope, additive_error, neutral )
  sr_list_run = SpatialEvolution.spatial_result_type[]
  trial=1
  for N in N_list
    for num_subpops in num_subpops_list
      for ne in ne_list
        for use_fit_locations in use_fit_locations_list
          #for extreme_variation in extreme_variation_list
          for horiz_select in horiz_select_list
            circular_variation = extreme_variation = false
            num_fit_locations = use_fit_locations ? maximum(num_subpops_list) : num_subpops
            println("num_subpops: ",num_subpops,"  num_fit_locations: ",num_fit_locations)
            sr = SpatialEvolution.spatial_result(N,num_subpops,num_fit_locations,ne,num_attributes, mu, ngens, burn_in,
                use_fit_locations, horiz_select, circular_variation, extreme_variation, normal_stddev, ideal_max, ideal_min, ideal_range,
                fit_slope, additive_error, neutral )
            Base.push!(sr_list_run, sr )
            #println("= = = = = = = =")
            #writerow(STDOUT,trial,sr)
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

if length(ARGS) == 0
  simname = "configs/example2"
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
#println("simtype: ",simtype)
run_trials( simname )
