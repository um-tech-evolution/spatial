#=
Recommended command line to run:
>  julia -L ContVarEvolution.jl run.jl configs/example1
=#
export spatial_result, print_spatial_result, run_trial, writeheader, writerow
#include("types.jl")
  
function spatial_result( N::Int64, num_subpops::Int64, num_fit_locations::Int64, ne::Int64, num_attributes::Int64, mu::Float64, ngens::Int64, burn_in::Float64,
    use_fit_locations::Bool, horiz_select::Bool, circular_variation::Bool, extreme_variation::Bool, normal_stddev::Float64,
      ideal_max, ideal_min, ideal_range )
  return spatial_result_type( N, num_subpops, num_fit_locations, ne, num_attributes, mu, ngens, burn_in,
    use_fit_locations, horiz_select, circular_variation, extreme_variation, normal_stddev, ideal_max, ideal_min, ideal_range, 0.0, 0.0, 0.0 )
end

function print_spatial_result( sr::spatial_result_type )
  println("N: ", sr.N)
  println("num_subpops: ", sr.num_subpops)
  println("num_fit_locations: ", sr.num_fit_locations)
  println("ne: ", sr.ne)
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
  println("fitness_coef_var: ", sqrt(sr.fitness_variance)/sr.fitness_mean)
  println("attiribute_coef_var: ", sqrt(sr.attribute_variance)/sr.fitness_mean)
end

function writeheader( stream::IO, sr::spatial_result_type )
  param_strings = [
    "# $(string(Dates.today()))",
    #"# N=$(sr.N)",
    #"# num_subpops_list=$(num_subpops_list)",
    #"# num_attributes=$(sr.num_attributes)",
    "# mu=$(sr.mu)",
    "# horiz_select=$(sr.horiz_select)",
    #"# num_emmigrants=$(sr.ne)",
    "# ngens=$(sr.ngens)",
    "# num_emigrants=$(sr.ne)",
    "# use_fit_locations=$(sr.use_fit_locations)",
    "# num_fit_locations=$(sr.num_fit_locations)",
    "# circular_variation=$(sr.circular_variation)",
    "# extreme_variation=$(sr.extreme_variation)",
    "# burn_in=$(sr.burn_in)",
    "# normal_stddev=$(sr.normal_stddev)",
    "# ideal_max=$(sr.ideal_max)",
    "# ideal_min=$(sr.ideal_min)",
    "# ideal_range=$(sr.ideal_range)"]

  write(stream,join(param_strings,"\n"),"\n")
  heads = [
    "N",
    "num_subpops",
    "subpop_size",
    "normal_stddev",
    #"num_emigrants",
    #"use_fit_locations",
    #"num_fit_locations",
    "num_attributes",
    #"circular_variation",
    #"extreme_variation",
    #"horiz_select",
    "mean_fitness",
    "fitness_coef_var",
    "attribute_coef_var"]
  write(stream,join(heads,","),"\n")
end
    
function writerow( stream::IO, trial::Int64, sr::spatial_result_type )
  line = Any[
          sr.N,
          sr.num_subpops,
          Int(ceil(sr.N/sr.num_subpops)),
          sr.normal_stddev,
          #sr.ne,
          #sr.use_fit_locations,
          #sr.num_fit_locations,
          sr.num_attributes,
          #sr.circular_variation,
          #sr.extreme_variation,
          #sr.horiz_select,
          sr.fitness_mean,
          sqrt(sr.fitness_variance)/sr.fitness_mean,
          sqrt(sr.attribute_variance)/sr.fitness_mean]
  write(stream,join(line,","),"\n")
end


if isdefined(:simtype)
  run_trials()
end