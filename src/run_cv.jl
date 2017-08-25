using ContVarEvolution

function run_trials( simname::AbstractString ) 
  stream = open("$(simname).csv","w")
  println("stream: ",stream)
  sr = ContVarEvolution.spatial_result(N_list[1],num_subpops,num_fit_locations,ne,num_attributes_list[1], mu, ngens, burn_in,
      use_fit_locations, horiz_select, circular_variation, extreme_variation, normal_stddev_list[1], ideal_max, ideal_min, ideal_range )
  sr_list_run = ContVarEvolution.spatial_result_type[]
  trial=1
  for N in N_list
    for num_attributes in num_attributes_list
      for normal_stddev in normal_stddev_list
            circular_variation = extreme_variation = false
            #println("num_fit_locations: ",num_fit_locations)
            sr = ContVarEvolution.spatial_result(N,num_subpops,num_fit_locations,ne,num_attributes, mu, ngens, burn_in,
               use_fit_locations, horiz_select, circular_variation, extreme_variation, normal_stddev, ideal_max, ideal_min, ideal_range )
            Base.push!(sr_list_run, sr )
            #println("= = = = = = = =")
            #writerow(STDOUT,trial,sr)
      end
    end
  end
  println("===================================")
  sr_list_result = pmap(spatial_simulation, sr_list_run )
  trial = 1
  writeheader( stream, sr )
  writeheader( STDOUT, sr )
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
