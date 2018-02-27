export variant_type, fitness_location_type
const Population = Array{Int64,1}
const PopList = Array{Population,1}

type variant_type
  parent::Int64   # The variant that gave rise to this variant
  fitness::Float64    # The fitness of this variant
  fitness_location::Int64  # the fitness location of this variant
  attributes::Vector{Float64}   # attributes of the variant
end

type fitness_location_type
  ideal::Vector{Float64}   # Ideal values for attributes in the environment of this subpop
end

type spatial_result_type
  num_trials::Int64
  N::Int64   # meta-population size
  num_subpops::Int64   # number of subpopulations
  subpop_size::Int64   # size of subpops.  Calculated as N/num_subpops
  num_fit_locations::Int64   # number of "subpopulations" to use for env variation.  
  num_emmigrants::Int64       # num emigrants
  num_attributes::Int64  # number of attributes of a variant
  mu::Float64     # innovation rate
  ngens::Int64  # number of generations after burn-in
  int_burn_in::Int64
  use_fit_locations::Bool  # Whether to use fitness locations other than subpopulations
  horiz_select::Bool       # Whether to use selection during horzontal transfer
  linear_variation::Bool    # Whether to vary ideal values in a circular fashion
  extreme_variation::Bool    # Whether to vary ideal values by randomly choosing between high and low values
  normal_stddev::Float64  # standard deviation of normal distribution of mutation perturbations
  #patchy::Bool            # patchy==true corresponds to ideal_max=0.8, ideal_min=0.2, ideal_range=0.0  (changed ideal_range to 0.0 on 2/25/18)
  ideal_max::Float64      # maximum ideal value for circular and extreme ideal values
  ideal_min::Float64      # minimum ideal value for circular and extreme ideal values
  ideal_range::Float64    # range of ideal values for circular and extreme ideal 
  fit_slope::Float64      # If fit_slope> 0.0, use inverse fitness with this fit_slope.  Otherwise, linear fitness
  additive_error::Bool    # If true, use additive error with wrapping.  If false, use multiplicative copy error without wrapping
  neutral::Bool           # if true, no selection, do not run proportional selection
  fitness_mean::Float64
  fitness_variance::Float64
  attribute_variance::Float64
  attribute_coef_var::Float64
end

