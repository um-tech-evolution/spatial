#=
Recommended command line to run:
>  julia -L SpatialEvolution.jl run.jl configs/example1
=#
export spatial_result, print_spatial_result, run_trial, writeheader, writerow
#include("types.jl")
  
function spatial_result( num_trials::Int64, N::Int64, num_subpops::Int64, num_fit_locations::Int64, ne::Int64, num_attributes::Int64, mu::Float64, ngens::Int64, 
    burn_in::Number, use_fit_locations::Bool, horiz_select::Bool, circular_variation::Bool, extreme_variation::Bool, normal_stddev::Float64,
      patchy::Bool, ideal_max::Float64, ideal_min::Float64, ideal_range::Float64, fit_slope::Float64, additive_error::Bool, neutral::Bool )
  if typeof(burn_in) == Int64
    int_burn_in = burn_in
  else
    int_burn_in = Int(round(burn_in*N))   # Same as March 2017 
  end
  return spatial_result_type( num_trials, N, num_subpops, num_fit_locations, ne, num_attributes, mu, ngens, int_burn_in,
    use_fit_locations, horiz_select, circular_variation, extreme_variation, normal_stddev, patchy, ideal_max, ideal_min, ideal_range, 
    fit_slope, additive_error, neutral, 0.0, 0.0, 0.0, 0.0 )
end

#=
function print_spatial_result( sr::spatial_result_type )
  println("N: ", sr.N)
  println("num_subpops: ", sr.num_subpops)
  println("num_fit_locations: ", sr.num_fit_locations)
  println("ne: ", sr.num_emmigrants)
  println("num_attributes: ", sr.num_attributes)
  println("mu: ", sr.mu)
  println("normal_stddev: ", sr.normal_stddev)
  println("ngens: ", sr.ngens)
  println("burn_in: ", sr.burn_in)
  println("use_fit_locations: ", sr.use_fit_locations)
  println("horiz_select: ", sr.horiz_select)
  println("circular_variation: ",sr.circular_variation)
  println("extreme_variation: ",sr.extreme_variation)
  println("fitness_mean: ", sr.fitness_mean)
  println("fitness_variance: ", sr.fitness_variance)
  println("attiribute_variance: ", sr.attribute_variance)
end
=#

function writeheader( stream::IO, num_subpops_list::Vector{Int64}, sr::spatial_result_type )
  param_strings = [
    "# $(string(Dates.today()))",
    "# num_trials=$(sr.num_trials)",
    #"# N=$(sr.N)",
    "# num_subpops_list=$(num_subpops_list)",
    #"# num_attributes=$(sr.num_attributes)",
    "# mu=$(sr.mu)",
    #"# horiz_select=$(sr.horiz_select)",
    #"# num_emmigrants=$(sr.num_emmigrants)",
    "# ngens=$(sr.ngens)",
    #"# circular_variation=$(sr.circular_variation)",
    #"# extreme_variation=$(sr.extreme_variation)",
    #"# int_burn_in=$(sr.int_burn_in)",
    "# normal_stddev=$(sr.normal_stddev)",
    "# ideal_max=$(sr.ideal_max)",
    "# ideal_min=$(sr.ideal_min)",
    "# ideal_range=$(sr.ideal_range)",
    "# fit_slope=$(sr.fit_slope)",
    "# additive_error=$(sr.additive_error)",
    "# neutral=$(sr.neutral)"
  ]

  write(stream,join(param_strings,"\n"),"\n")
  heads = [
    "N",
    "num_subpops",
    "subpop_size",
    "normal_stddev",
    "num_emigrants",
    "int_burn_in",
    "use_fit_locations",
    "num_fit_locations",
    "num_attributes",
    "circular_variation",
    "extreme_variation",
    "horiz_select",
    "fitness_mean",
    "fitness_coef_var",
    "attribute_variance",
    "attribute_coef_var"
  ]
  write(stream,join(heads,","),"\n")
end
    
function writerow( stream::IO, trial::Int64, sr::spatial_result_type )
  line = Any[
          sr.N,
          sr.num_subpops,
          Int(ceil(sr.N/sr.num_subpops)),
          sr.normal_stddev,
          sr.num_emmigrants,
          sr.int_burn_in,
          sr.use_fit_locations,
          sr.num_fit_locations,
          sr.num_attributes,
          sr.circular_variation,
          sr.extreme_variation,
          sr.horiz_select,
          sr.fitness_mean,
          sqrt(sr.fitness_variance)/sr.fitness_mean,
          #sqrt(sr.attribute_variance)/sr.fitness_mean]
          sr.attribute_variance,
          sr.attribute_coef_var
    ]
  write(stream,join(line,","),"\n")
end


if isdefined(:simtype)
  run_trials()
end
