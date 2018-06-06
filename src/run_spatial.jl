#=
Recommended command line to run:
>  julia run.jl examples/example1
=#
export run_trials, spatial_result, print_spatial_result, run_trial, writeheader, writerow, fixed_fields
#include("types.jl")

function run_trials( simname::AbstractString, sr::SpatialEvolution.spatial_result_type ) 
  stream = open("$(simname).csv","w")
  println("stream: ",stream)
  println("burn_in: ",sr.burn_in)
  num_fit_locations = sr.use_fit_locations_list[1] ? maximum(sr.num_subpops_list) : sr.num_subpops_list[1]
  #println("N: ",N,"  num_fit_locations: ",numm_fit_locations)
  sr_list_run = SpatialEvolution.spatial_run_result_type[]
  trial=1
  for N in sr.N_list
    for num_subpops in sr.num_subpops_list
      for num_emigrants in sr.num_emigrants_list
        for use_fit_locations in sr.use_fit_locations_list
          for extreme_variation in sr.extreme_variation_list
            for linear_variation in sr.linear_variation_list
              if !(extreme_variation && linear_variation)   # extreme variation and circular variation are not compatible
                for horiz_select in sr.horiz_select_list
                  if num_emigrants==0 && horiz_select continue end  # horiz_select doesn't make sense with no emigrants
                  num_fit_locations = use_fit_locations ? maximum(sr.num_subpops_list) : num_subpops
                  for num_attributes in sr.num_attributes_list
                    for mu in sr.mu_list
                      srr = SpatialEvolution.spatial_run_result(sr.num_trials, N,num_subpops,num_fit_locations,num_emigrants,num_attributes, 
                           mu, sr.ngens, sr.burn_in, use_fit_locations, horiz_select, linear_variation, extreme_variation, sr.normal_stddev, 
                            sr.fit_slope, sr.additive_error, sr.neutral )
                      for trial = 1:sr.num_trials
                        Base.push!(sr_list_run, deepcopy(srr) )
                      end
                      println("N: ",srr.N,"  num_subpops: ",srr.num_subpops,"  num_fit_locations: ",srr.num_fit_locations,"  num_attributes: ",srr.num_attributes,"  mu: ",srr.mu  )
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
  #sr_list_result = map(spatial_simulation, sr_list_run )
  #println("pmap done")
  #out_df = build_dataframe_from_type( SpatialEvolution.spatial_result_type, length(sr_list_result) )
  #fixd_fields = fixed_fields()
  #println("build df done")
  writeheader( "$(simname).csv", sr )
  i = 1
  for sr_result in sr_list_result
    #add_row_to_dataframe(out_df,sr_result,i)
    writerow("$(simname).csv", sr_result )
    i += 1
  end
  #CSV.write( "$(simname).csv", out_df, header=true, append=true )
end    

  
function spatial_result( seed::Int64, num_trials::Int64, N_list::Vector{Int64}, num_subpops_list::Vector{Int64}, num_fit_locations::Int64, 
    num_emigrants_list::Vector{Int64}, num_attributes_list::Vector{Int64}, mu_list::Vector{Float64}, ngens::Int64, 
    burn_in::Number, use_fit_locations_list::Vector{Bool}, horiz_select_list::Vector{Bool}, 
    linear_variation_list::Vector{Bool}, extreme_variation_list::Vector{Bool}, normal_stddev::Float64,
      fit_slope::Float64, additive_error::Bool, neutral::Bool )
  return spatial_result_type( seed, num_trials, N_list, num_subpops_list,  
    num_emigrants_list, num_attributes_list, mu_list, ngens, burn_in,
    use_fit_locations_list, horiz_select_list, linear_variation_list, extreme_variation_list, 
    normal_stddev, fit_slope, additive_error, neutral, 0.0, 0.0, 0.0, 0.0 )
end

function spatial_run_result( num_trials::Int64, N::Int64, num_subpops::Int64, num_fit_locations::Int64,
    num_emigrants::Int64, num_attributes::Int64, mu::Float64, ngens::Int64,
    burn_in::Number, use_fit_locations::Bool, horiz_select::Bool,
    linear_variation::Bool, extreme_variation::Bool, normal_stddev::Float64,
       fit_slope::Float64, additive_error::Bool, neutral::Bool )
  if typeof(burn_in) == Int64
    int_burn_in = burn_in
  else
    int_burn_in = Int(round(burn_in*N))   # Same as March 2017
  end
  if use_fit_locations
    ideal_max=0.8;  ideal_min=0.2  # changed from 0.1 to 0.0 on Feb. 25, 2018
  else
    if linear_variation==false && extreme_variation == false
      ideal_max=0.5;  ideal_min=0.5;  ideal_range=0.0
    else
      ideal_max=0.8;  ideal_min=0.2;  ideal_range=0.0
    end
  end
  subpop_size = floor( Int(N/num_subpops))

  return spatial_run_result_type( num_trials, N, num_subpops, subpop_size, num_fit_locations, num_emigrants, num_attributes,
    mu, ngens, int_burn_in,
    use_fit_locations, horiz_select, linear_variation, extreme_variation, normal_stddev, ideal_max, ideal_min,
    fit_slope, additive_error, neutral, 0.0, 0.0, 0.0, 0.0 )
end

#=
function print_spatial_result( sr::spatial_result_type )
  println("N: ", sr.N)
  println("num_subpops: ", sr.num_subpops)
  println("num_fit_locations: ", sr.num_fit_locations)
  println("ne: ", sr.nem_emigrants)
  println("num_attributes: ", sr.num_attributes)
  println("mu: ", sr.mu)
  println("normal_stddev: ", sr.normal_stddev)
  println("ngens: ", sr.ngens)
  println("burn_in: ", sr.burn_in)
  println("use_fit_locations: ", sr.use_fit_locations)
  println("horiz_select: ", sr.horiz_select)
  println("linear_variation: ",sr.linear_variation)
  println("extreme_variation: ",sr.extreme_variation)
  println("fitness_mean: ", sr.fitness_mean)
  println("fitness_variance: ", sr.fitness_variance)
  println("attiribute_variance: ", sr.attribute_variance)
end
=#

function fixed_parameters()  # included as comments in output csv file
[ 
  :random_number_seed,
  :N_list,
  :num_subpops_list,
  :num_emigrants_list,
  :num_attributes_list,
  :use_fit_locations_list,
  :linear_variation_list,
  :extreme_variation_list,
  :num_trials,
  :ngens,
  :mu_list,
  :burn_in,
  :normal_stddev,
  :fit_slope,
  :additive_error,
  :neutral
]
end

function varying_parameters()    # included as column headers in output csv file
[ 
  :N,
  :num_subpops,
  :subpop_size,
  :mu,
  :num_fit_locations,
  :num_emigrants,
  :num_attributes,
  :use_fit_locations,
  :horiz_select,
  :int_burn_in,
  :ideal_max,
  :ideal_min,
  :linear_variation,
  :extreme_variation,
]
end

function output_columns()
[
  :fitness_mean,
  :fitness_variance,
  :attribute_variance,
  :attribute_coef_var,
]
end


#function writeheader( filename::AbstractString, fixed_fields::Array{Symbol,1}, sr::SpatialEvolution.spatial_result_type )
function writeheader( filename::AbstractString, sr::SpatialEvolution.spatial_result_type )
  param_strings = [ "# $(string(s))=$(getfield(sr,s))" for s in fixed_parameters()]
  #println("len ps: ",length(param_strings))
  #println("ps: ",param_strings)
  open(filename,"w") do str
    write(str,"# $(string(Dates.today()))\n")
    write(str,join(param_strings,"\n"),"\n")
    write(str,join(map(string,varying_parameters()),","),",")
    write(str,join(map(string,output_columns()),","),"\n")
  end
end

#function writerow( filename::AbstractString, fixed_fields::Array{Symbol,1}, sr::SpatialEvolution.spatial_run_result_type )
function writerow( filename::AbstractString, sr::SpatialEvolution.spatial_run_result_type ) 
  param_vals = Any[ getfield( sr, s) for s in varying_parameters()]
  output_vals = Any[ getfield( sr, s) for s in output_columns()]
  #print("len vals: ",length(vals))
  #println("  vals: ",vals)
  #println("num_attributes: ",sr.num_attributes)
  #println("jvals: ",join(vals,","))
  open(filename,"a") do str
    write(str,join(param_vals,","),",")
    write(str,join(output_vals,","),"\n")
    #println(join(vals,","))
  end
end


