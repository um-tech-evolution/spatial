using SpatialEvolution
# Suggested command-line execution:  >  julia -L SpatialEvolution.jl run.jl configs/example1

function run_trials( simname::AbstractString ) 
  csv_filename = "$(simname).csv"
  #stream = open("$(simname).csv","w")
  #println("stream: ",stream)
  num_fit_locations = use_fit_locations_list[1] ? maximum(num_subpops_list) : num_subpops_list[1]
  sr = SpatialEvolution.spatial_result(num_trials, N_list[1],num_subpops_list[1],num_fit_locations,num_emmigrants_list[1],num_attributes_list[1], mu, ngens, burn_in,
      use_fit_locations_list[1], horiz_select_list[1], linear_variation_list[1], extreme_variation_list[1], normal_stddev, 
      patchy_list[1], fit_slope, additive_error, neutral )
  sr_list_run = SpatialEvolution.spatial_result_type[]
  trial=1
  for N in N_list
    for num_subpops in num_subpops_list
      for num_emmigrants in num_emmigrants_list
        for use_fit_locations in use_fit_locations_list
          for patchy in patchy_list
            for extreme_variation in extreme_variation_list
              for linear_variation in linear_variation_list
                if !(extreme_variation && linear_variation)   # extreme variation and circular variation are not compatible
                  for horiz_select in horiz_select_list
                    if num_emmigrants==0 && horiz_select continue end  # horiz_select doesn't make sense with no emmigrants
                    num_fit_locations = use_fit_locations ? maximum(num_subpops_list) : num_subpops
                    for num_attributes in num_attributes_list
                      for trial = 1:num_trials
                        sr = SpatialEvolution.spatial_result(num_trials, N,num_subpops,num_fit_locations,num_emmigrants,num_attributes, mu, ngens, burn_in,
                          use_fit_locations, horiz_select, linear_variation, extreme_variation, normal_stddev, 
                          patchy, fit_slope, additive_error, neutral )
                        println("num_subpops: ",sr.num_subpops,"  num_fit_locations: ",sr.num_fit_locations,"  num_attributes: ",sr.num_attributes  )
                        Base.push!(sr_list_run, sr )
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
  end
  println("===================================")
  sr_list_result = pmap(spatial_simulation, sr_list_run )
  println("pmap done")
  #=
  trial = 1
  writeheader( stream, fixed_fields(), sr )
  writeheader( STDOUT, num_subpops_list, sr )
  for sr_result in sr_list_result
    writerow(stream,trial,sr_result)
    writerow(STDOUT,trial,sr_result)
    trial += 1
  end
  close(stream)
  =#
  out_df = build_dataframe_from_type( SpatialEvolution.spatial_result_type, length(sr_list_result) )
  fixd_fields = fixed_fields()
  println("build df done")
  writeheader( "$(simname).csv", fixed_fields(), sr )
  i = 1
  for sr_result in sr_list_result
    add_row_to_dataframe(out_df,sr_result,i)
    writerow("$(simname).csv", fixd_fields, sr_result )
    if i % 1000 == 0
      println("i: ",i,"  row")
    end
    i += 1
  end
  #CSV.write( "$(simname).csv", out_df, header=true, append=true )
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
