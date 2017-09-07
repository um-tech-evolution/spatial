export variant_type, fitness_location_type
#using Distributions
const Population = Array{Int64,1}
const PopList = Array{Population,1}

type variant_type
  parent::Int64   # The variant that gave rise to this variant
  fitness::Float64    # The fitness of this variant
  attributes::Vector{Float64}   # attributes of the variant
end

type spatial_result_type
  N::Int64   # meta-population size
  num_subpops::Int64   # number of subpopulations
  #num_fit_locations::Int64   # number of "subpopulations" to use for env variation.  0 means use num_subpops.
  #ne::Int64  # number of emmigrants in horizontal transfer
  num_attributes::Int64  # number of attributes of a variant
  mu::Float64     # innovation rate
  ngens::Int64  # number of generations after burn-in
  burn_in::Float64
  #horiz_select::Bool       # Whether to use selection during horzontal transfer
  mutation_stddev::Float64  # standard deviation of mutation distribution of mutation perturbations
  ideal::Float64      #maximum ideal value 
  fitness_mean::Float64
  fitness_variance::Float64
  attribute_variance::Float64
  neg_count::Int64        # Number of fitness differences < -1.0/N
  neg_neutral::Int64      # Number of fitness differences >= -1.0/N  and < 0.0
  pos_neutral::Int64     # Number of fitness differences >= 0.0 and < 1.0/N
  pos_count::Int64        # Number of fitness differences >= 1.0/N
  #fit_diff_list::Vector{Float64}
end

