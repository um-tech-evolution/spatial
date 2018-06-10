#=
Recommended command line to run:
>  julia run.jl configs/example1
=#
export run_trials, spatial_result, print_spatial_result, run_trial, writeheader, writerow
#include("types.jl")

function run_trials( simname::AbstractString, sr::SpatialEvolution.spatial_result_type ) 
  stream = open("$(simname).csv","w")
  println("stream: ",stream)
  println("burn_in: ",sr.burn_in)
  num_fit_locations = sr.use_fit_locations_list[1] ? maximum(sr.num_subpops_list) : sr.num_subpops_list[1]
  sr_list_run = SpatialEvolution.spatial_run_result_type[]
  trial=1
  for N in sr.N_list
    for num_subpops in sr.num_subpops_list
      for num_emigrants in sr.num_emigrants_list
        for use_fit_locations in sr.use_fit_locations_list
          for extreme_variation in sr.extreme_variation_list
            for circular_variation in sr.circular_variation_list
              if !(extreme_variation && circular_variation)   # extreme variation and circular variation are not compatible
                for horiz_select in sr.horiz_select_list
                  num_fit_locations = use_fit_locations ? maximum(sr.num_subpops_list) : num_subpops
                  for num_attributes in sr.num_attributes_list
                    for trial = 1:sr.num_trials
                      srr = SpatialEvolution.spatial_run_result(sr.num_trials, N,num_subpops,num_fit_locations,num_emigrants,num_attributes, 
                          sr.mu, sr.ngens, sr.burn_in,
                          use_fit_locations, horiz_select, circular_variation, extreme_variation, sr.normal_stddev, 
                          sr.patchy, sr.ideal_max, sr.ideal_min, sr.ideal_range, sr.fit_slope, sr.additive_error, sr.neutral )
                      println("num_subpops: ",srr.num_subpops,"  num_fit_locations: ",srr.num_fit_locations,"  num_attributes: ",srr.num_attributes  )
                      Base.push!(sr_list_run, srr )
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
  writeheader( stream, sr.num_subpops_list, sr )
  writeheader( STDOUT, sr.num_subpops_list, sr )
  for sr_result in sr_list_result
    writerow(stream,trial,sr_result)
    writerow(STDOUT,trial,sr_result)
    trial += 1
  end
end    
  
function spatial_result( num_trials::Int64, N_list::Vector{Int64}, num_subpops_list::Vector{Int64}, num_fit_locations::Int64, 
    num_emigrants_list::Vector{Int64}, num_attributes_list::Vector{Int64}, mu::Float64, ngens::Int64, 
    burn_in::Number, use_fit_locations_list::Vector{Bool}, horiz_select_list::Vector{Bool}, 
    circular_variation_list::Vector{Bool}, extreme_variation_list::Vector{Bool}, normal_stddev::Float64,
      patchy::Bool, ideal_max::Float64, ideal_min::Float64, ideal_range::Float64, fit_slope::Float64, additive_error::Bool, neutral::Bool )
  #=
  if typeof(burn_in) == Int64
    int_burn_in = burn_in
  else
    int_burn_in = Int(round(burn_in*N))   # Same as March 2017 
  end
  =#
  if patchy
    ideal_max=0.8;  ideal_min=0.2;  ideal_range=0.0  # changed from 0.1 to 0.0 on Feb. 25, 2018
  #else
  #  if circular_variation==false && extreme_variation == false
  #    ideal_max=0.5;  ideal_min=0.5;  ideal_range=0.0
  #  else
  #    ideal_max=0.8;  ideal_min=0.2;  ideal_range=0.0
  #  end
  end

  return spatial_result_type( num_trials, N_list, num_subpops_list, num_fit_locations, num_emigrants_list, num_attributes_list, 
    mu, ngens, burn_in,
    use_fit_locations_list, horiz_select_list, circular_variation_list, extreme_variation_list, normal_stddev, patchy, ideal_max, ideal_min, ideal_range, 
    fit_slope, additive_error, neutral, 0.0, 0.0, 0.0, 0.0 )
end

function spatial_run_result( num_trials::Int64, N::Int64, num_subpops::Int64, num_fit_locations::Int64, 
    num_emigrants::Int64, num_attributes::Int64, mu::Float64, ngens::Int64, 
    burn_in::Number, use_fit_locations::Bool, horiz_select::Bool, 
    circular_variation::Bool, extreme_variation::Bool, normal_stddev::Float64,
      patchy::Bool, ideal_max::Float64, ideal_min::Float64, ideal_range::Float64, fit_slope::Float64, additive_error::Bool, neutral::Bool )
  if typeof(burn_in) == Int64
    int_burn_in = burn_in
  else
    int_burn_in = Int(round(burn_in*N))   # Same as March 2017 
  end
  if patchy
    ideal_max=0.8;  ideal_min=0.2;  ideal_range=0.0  # changed from 0.1 to 0.0 on Feb. 25, 2018
  #else
  #  if circular_variation==false && extreme_variation == false
  #    ideal_max=0.5;  ideal_min=0.5;  ideal_range=0.0
  #  else
  #    ideal_max=0.8;  ideal_min=0.2;  ideal_range=0.0
  #  end
  end

  return spatial_run_result_type( num_trials, N, num_subpops, num_fit_locations, num_emigrants, num_attributes, 
    mu, ngens, int_burn_in,
    use_fit_locations, horiz_select, circular_variation, extreme_variation, normal_stddev, patchy, ideal_max, ideal_min, ideal_range, 
    fit_slope, additive_error, neutral, 0.0, 0.0, 0.0, 0.0 )
end

#=
function print_spatial_result( sr::spatial_result_type )
  println("N: ", sr.N)
  println("num_subpops: ", sr.num_subpops)
  println("num_fit_locations: ", sr.num_fit_locations)
  println("ne: ", sr.num_emigrants)
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
    #"# num_emigrants=$(sr.num_emigrants)",
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
    
function writerow( stream::IO, trial::Int64, sr::spatial_run_result_type )
  line = Any[
          sr.N,
          sr.num_subpops,
          Int(ceil(sr.N/sr.num_subpops)),
          sr.normal_stddev,
          sr.num_emigrants,
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

