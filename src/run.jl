# Suggested command-line execution:  > julia run.jl configs/example1 1   # 1 is the random number seed
# Suggested command-line execution:  > julia -p 4 run.jl configs/example1 1  # 4 is the number of cores

@everywhere include("SpatialEvolution.jl")
#=
function run_trials( simname::AbstractString ) 
  csv_filename = "$(simname).csv"
  #stream = open("$(simname).csv","w")
  #println("stream: ",stream)
  num_fit_locations = use_fit_locations_list[1] ? maximum(num_subpops_list) : num_subpops_list[1]
  #println("N: ",N,"  num_fit_locations: ",numm_fit_locations)
  sr = SpatialEvolution.spatial_result(num_trials, N_list[1],num_subpops_list[1],num_fit_locations,num_emmigrants_list[1],num_attributes_list[1], mu_list[1], ngens, burn_in,
      use_fit_locations_list[1], horiz_select_list[1], linear_variation_list[1], extreme_variation_list[1], normal_stddev, 
      fit_slope, additive_error, neutral )
  sr_list_run = SpatialEvolution.spatial_result_type[]
  trial=1
  for N in N_list
    for num_subpops in num_subpops_list
      for num_emmigrants in num_emmigrants_list
        for use_fit_locations in use_fit_locations_list
          for extreme_variation in extreme_variation_list
            for linear_variation in linear_variation_list
              if !(extreme_variation && linear_variation)   # extreme variation and circular variation are not compatible
                for horiz_select in horiz_select_list
                  if num_emmigrants==0 && horiz_select continue end  # horiz_select doesn't make sense with no emmigrants
                  num_fit_locations = use_fit_locations ? maximum(num_subpops_list) : num_subpops
                  for num_attributes in num_attributes_list
                    for mu in mu_list
                      for trial = 1:num_trials
                        sr = SpatialEvolution.spatial_result(num_trials, N,num_subpops,num_fit_locations,num_emmigrants,num_attributes, mu, ngens, burn_in,
                          use_fit_locations, horiz_select, linear_variation, extreme_variation, normal_stddev, 
                          fit_slope, additive_error, neutral )
                        Base.push!(sr_list_run, sr )
                      end
                      println("N: ",sr.N,"  num_subpops: ",sr.num_subpops,"  num_fit_locations: ",sr.num_fit_locations,"  num_attributes: ",sr.num_attributes,"  mu: ",mu  )
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
  #println("pmap done")
  out_df = build_dataframe_from_type( SpatialEvolution.spatial_result_type, length(sr_list_result) )
  fixd_fields = fixed_fields()
  #println("build df done")
  writeheader( "$(simname).csv", fixed_fields(), sr )
  i = 1
  for sr_result in sr_list_result
    add_row_to_dataframe(out_df,sr_result,i)
    writerow("$(simname).csv", fixd_fields, sr_result )
    #=
    if i % 1000 == 0
      println("i: ",i,"  row")
    end
    =#
    i += 1
  end
  #CSV.write( "$(simname).csv", out_df, header=true, append=true )
end    
=#


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


global seed = 1
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
run_trials( simname, sim_record )

