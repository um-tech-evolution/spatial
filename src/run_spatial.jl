#=
Recommended command line to run:
>  julia -L SpatialEvolution.jl run.jl configs/example1
=#
export spatial_result, print_spatial_result, run_trial, writeheader, writerow, fixed_fields
#include("types.jl")
  
function spatial_result( num_trials::Int64, N::Int64, num_subpops::Int64, num_fit_locations::Int64, ne::Int64, num_attributes::Int64, mu::Float64, ngens::Int64, 
    burn_in::Number, use_fit_locations::Bool, horiz_select::Bool, linear_variation::Bool, extreme_variation::Bool, normal_stddev::Float64,
      fit_slope::Float64, additive_error::Bool, neutral::Bool )
  if typeof(burn_in) == Int64
    int_burn_in = burn_in
  else
    int_burn_in = Int(round(burn_in*N))   # Same as March 2017 
  end
  if use_fit_locations
    ideal_max=0.8;  ideal_min=0.2;  # removed ideal_range on 2/27/18
  else
    if linear_variation==false && extreme_variation == false  # interpret as uniform variation
      ideal_max=0.5;  ideal_min=0.5;  
    else
      ideal_max=0.8;  ideal_min=0.2;  
    end
  end
  subpop_size = N/num_subpops
  return spatial_result_type( num_trials, N, num_subpops, subpop_size, num_fit_locations, ne, num_attributes, mu, ngens, int_burn_in,
    use_fit_locations, horiz_select, linear_variation, extreme_variation, normal_stddev, ideal_max, ideal_min, 
    fit_slope, additive_error, neutral, 0.0, 0.0, 0.0, 0.0 )
end

#=
function print_spatial_result( sr::spatial_result_type )
  println("N: ", sr.N)
  println("num_subpops: ", sr.num_subpops)
  println("num_fit_locations: ", sr.num_fit_locations)
  println("ne: ", sr.nem_emmigrants)
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

function fixed_fields()  
[ :num_trials,
 :ngens,
 :normal_stddev,
 :ideal_max,
 :ideal_min,
 :fit_slope,
 :additive_error,
 :neutral
]
end

function writeheader( filename::AbstractString, fixed_fields::Array{Symbol,1}, sr::SpatialEvolution.spatial_result_type )
  param_strings = [ "# $(string(s))=$(getfield(sr,s))" for s in fixed_fields]
  #println("len ps: ",length(param_strings))
  #println("ps: ",param_strings)
  #println("len re: ",length(remove_elements(fieldnames(SpatialEvolution.spatial_result_type),fixed_fields)))
  #println("re: ",remove_elements(fieldnames(SpatialEvolution.spatial_result_type),fixed_fields))
  open(filename,"w") do str
    write(str,"# $(string(Dates.today()))\n")
    write(str,join(param_strings,"\n"),"\n")
    write(str,join(map(string,remove_elements(fieldnames(SpatialEvolution.spatial_result_type),fixed_fields)),","),"\n")
  end
end

function writerow( filename::AbstractString, fixed_fields::Array{Symbol,1}, sr::SpatialEvolution.spatial_result_type )
  vals = Any[ getfield( sr, s) for s in remove_elements(fieldnames(SpatialEvolution.spatial_result_type),fixed_fields) ]
  #print("len vals: ",length(vals))
  #println("  vals: ",vals)
  #println("num_attributes: ",sr.num_attributes)
  #println("jvals: ",join(vals,","))
  open(filename,"a") do str
    write(str,join(vals,","),"\n")
    #println(join(vals,","))
  end
end



if isdefined(:simtype)
  run_trials()
end
