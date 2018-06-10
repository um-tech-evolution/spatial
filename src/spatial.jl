# Spatial structure simulation with horizontal transfer
export spatial_simulation, fitness

empty_variant = variant_type(-1,0.0,0,Vector{Float64}())
#vtbl = Dict{Int64,variant_type}()

@doc """ function spatial_simulation()
  Wright-Fisher model simulation (as opposed to Moran model)
  Parameters:
    N     MetaPopulation size
    m     number of subpopulations   # for now, subpopulation size = N/m
    mu    innovation probability
    ngens number of generations
    num_emigrants   number of emigrants in horizontal transfer
    num_attributes   number of quantitative attributes of a variant
    variant_table Keeps track fitnesses and variant parent and innovation ancestor
    quantitative==true means individuals have quantitative attributes, fitness computed by distance from ideal
    forward==true  means that horizontal transfer is done in a forward linear fashion
    extreme==true  means that horizontal transfer is done in a forward linear fashion
    neg_select==true  means that reverse proportional selection is used to select individuals to delete in horiz trans
"""
function spatial_simulation( sr::SpatialEvolution.spatial_run_result_type )
  println("N: ",sr.N,"  num_subpops: ",sr.num_subpops,"  num_fit_locations: ",sr.num_fit_locations,"  num_attributes: ",sr.num_attributes,"  mu: ",sr.mu  )
  variant_table = Dict{Int64,variant_type}()
  fitness_locations = initialize_fitness_locations(sr)
  id = Int[1]
  n = Int(floor(sr.N/sr.num_subpops))    # size of subpopulations
  #println("N: ",sr.N,"  num_subpops: ",sr.num_subpops,"  n: ",n,"  use fit locations: ",sr.use_fit_locations,"  num_attributes: ",sr.num_attributes,"  ngens: ",sr.ngens,"  ne: ",sr.num_emigrants)
  cumm_means = zeros(Float64,sr.num_subpops)
  cumm_variances = zeros(Float64,sr.num_subpops)
  cumm_attr_vars = zeros(Float64,sr.num_subpops)
  cumm_attr_coef_vars = zeros(Float64,sr.num_subpops)
  #pop_list = Vector{PopList}()
  # Initialize subpops
  subpops = PopList()
  for j = 1:sr.num_subpops
    Base.push!( subpops, Population() )
    for i = 1:n
      fit_loc_ind = fit_loc_index(sr.N,sr.num_subpops,sr.num_fit_locations,j,i)
      #println("j: ",j,"  i: ",i,"  fit_loc_ind: ",fit_loc_ind)
      Base.push!( subpops[j], new_innovation( id, 
          fit_loc_ind, sr.num_attributes, sr.neutral, sr.fit_slope, variant_table, fitness_locations ) )
    end
    #println("subpops[",j,"]: ",subpops[j], "  pop attr: ",[ variant_table[subpops[j][i]].attributes[1] for i = 1:n ] )
  end
  previous_variant_id = 1
  current_variant_id = id[1]
  #Base.push!(pop_list,deepcopy(subpops))
  previous_subpops = deepcopy(subpops)
  # The generational loop follows
  count_gens = 0
  for g = 1:sr.ngens+sr.int_burn_in
    #println("before g: ",g,"  pop: ",subpops[1],"  pop attr: ",[ variant_table[subpops[1][i]].attributes[1] for i = 1:n ])
    previous_previous_variant_id = previous_variant_id
    previous_variant_id = current_variant_id
    current_variant_id = id[1]
    #println("g: ",g,"  count_gens: ",count_gens)
    for j = 1:sr.num_subpops
      for i = 1:n
        fit_loc_ind = fit_loc_index(sr.N,sr.num_subpops,sr.num_fit_locations,j,i)
        cp = copy_parent( previous_subpops[j][i], id, fit_loc_ind, sr.mu, sr.normal_stddev, 
            sr.additive_error, sr.neutral, sr.fit_slope, variant_table, fitness_locations )
        subpops[j][i] = cp
      end
      #println("g:",g," j:",j,"  ",[(v,variant_table[v].attributes) for v in subpops[j]])
      if !sr.neutral
        subpops[j] = propsel( subpops[j], n, variant_table )
      else # Wright-Fisher copy
        r = rand(1:n,n)
        subpops[j] = subpops[j][ r ]
      end
      #println("B g: ",g,"  pop: ",subpops[j],"  pop attr: ",[ variant_table[subpops[j][i]].attributes[1] for i = 1:n ])
      #println("g: ",g,"  pop: ",subpops[j],"  pop fitnesses: ",[ variant_table[subpops[j][i]].fitness for i = 1:n ])
    end
    if sr.num_emigrants > 0 && g%2==0
      horiz_transfer_linear!( sr.N, sr.num_subpops, sr.num_emigrants, subpops, id, variant_table, fitness_locations, sr.fit_slope,
          forward=true, neg_select=sr.horiz_select, emigrant_select=sr.horiz_select, neutral=sr.neutral )
    elseif sr.num_emigrants > 0
      horiz_transfer_linear!( sr.N, sr.num_subpops, sr.num_emigrants, subpops, id, variant_table, fitness_locations, sr.fit_slope,
          forward=false, neg_select=sr.horiz_select, emigrant_select=sr.horiz_select, neutral=sr.neutral )
    end
    #=
    for j = 1:sr.num_subpops
      println("A g: ",g,"  pop: ",subpops[j],"  pop attr: ",[ variant_table[subpops[j][i]].attributes[1] for i = 1:n ])
    end
    =#
    previous_subpops = deepcopy(subpops)
    #print_pop(STDOUT,subpops,variant_table)
    if g > sr.int_burn_in
      count_gens += 1
      (mmeans,vvars) = means(subpops,variant_table)
      cumm_means += mmeans
      #println("mmeans: ",mmeans,"  cum_means: ",cumm_means)
      cumm_variances += vvars
      avars = attr_vars(subpops,variant_table, sr.num_attributes )
      avg_attr_coef_vars = attr_coef_vars(subpops,variant_table, sr.num_attributes )
      #println("avg_attr_coef_vars: ",avg_attr_coef_vars)
      cumm_attr_vars += avars
      cumm_attr_coef_vars += avg_attr_coef_vars
      #println("cumm_means: ",cumm_means)
      #println("cumm_variances: ",cumm_variances)
      #println("cumm_attr_vars: ",cumm_attr_vars)
      #println("cumm_attr_coef_vars: ",cumm_attr_coef_vars)
    end
    clean_up_variant_table(previous_previous_variant_id,previous_variant_id,variant_table)
  end  # for g
  cumm_means /= count_gens
  cumm_variances /= count_gens
  cumm_attr_vars /= count_gens
  cumm_attr_coef_vars /= count_gens
  #println("fitness mean: ",mean(cumm_means),"  variance: ",mean(cumm_variances),"  attribute_variance: ",mean(cumm_attr_vars))
  sr.fitness_mean = mean(cumm_means)
  sr.fitness_variance = mean(cumm_variances)
  sr.attribute_variance = mean(cumm_attr_vars)
  sr.attribute_coef_var = mean(cumm_attr_coef_vars)
  return sr
end

function fitness( attributes::Vector{Float64}, ideal::Vector{Float64}, neutral::Bool, fit_slope::Float64 )
  if neutral
    return 1.0
  end
  if length(attributes) != length(ideal)
    error("length(attributes) must equal length(ideal) in fitness")
  end
  dis = 0.0
  for k = 1:length(attributes)
    dis += abs( attributes[k] - ideal[k] )
  end
  #println("fitness: attributes: ",attributes,"  ideal: ",ideal," fit: ",1.0-dis/length(attributes))
  if fit_slope == 0.0  # use the older linear method of computing fitness
    result = max(1.0-dis/length(attributes),0.0)
  else  # inverse method of computing fitness added on 11/14/17
    result = 1.0/(fit_slope*dis+1.0)
    #println("fitness: attribute: ",attributes[1],"  ideal: ",ideal[1],"  result: ",result)
  end
  return result
end

function new_innovation( id::Vector{Int64}, 
    fit_loc_ind::Int64, num_attributes::Int64, neutral::Bool, fit_slope::Float64,
    variant_table::Dict{Int64,variant_type}, fitness_locations; quantitative::Bool=true )
  #println("new innov: ideal: ",fitness_locations[fit_loc_ind].ideal)
  i = id[1]
  if quantitative
    #println("new innovation i: ",i,"  fit_loc_ind:",fit_loc_ind,"  num_attributes: ",num_attributes )
    #variant_table[i] = variant_type( i, 0.0, fit_loc_ind, rand(num_attributes) )
    variant_table[i] = variant_type( i, 0.0, fit_loc_ind, fitness_locations[fit_loc_ind].ideal )
    #println("variant_table[i]: ",variant_table[i])
    variant_table[i].fitness = fitness( variant_table[i].attributes, fitness_locations[fit_loc_ind].ideal, neutral, fit_slope )  
  end
  id[1] += 1
  i
end

@doc """  copy_parent()
"""
function copy_parent( v::Int64, id::Vector{Int64}, fit_loc_ind::Int64, mu::Float64,
    normal_stddev::Float64, additive_error::Bool, neutral::Bool, fit_slope::Float64, variant_table::Dict{Int64,SpatialEvolution.variant_type},
    fitness_locations::Vector{SpatialEvolution.fitness_location_type} )
  i = id[1]
  vt = variant_table[v]
  new_attributes = mutate_attributes( vt.attributes, normal_stddev, additive_error )
  if mu > 0 && rand() < mu
    innovate_attribute( new_attributes, fit_loc_ind, fitness_locations )
  end
  #println("copy_parent v: ",v,"  fit_loc_ind: ",fit_loc_ind)
  #println("copy_parent v: ",v,"  attributes: ",vt.attributes)
  new_fit = fitness( new_attributes, fitness_locations[fit_loc_ind].ideal, neutral, fit_slope )
  #println("copy_parent i: ",i,"  quantitative: ",quantitative,"  new_fit: ",new_fit)
  variant_table[i] = deepcopy(vt)
  variant_table[i].fitness = new_fit
  variant_table[i].attributes = new_attributes
  #variant_table[i] = variant_type(v,new_fit,vt.fitness_location,vt.attributes)  # needs to be fixed
  #println("v: ",v,"  i: ",i,"  new_fit: ",new_fit,"  vtbl[i]: ",variant_table[i].fitness)
  id[1] += 1
  return i
end  

function mutate_attributes( attributes::Vector{Float64}, normal_stddev::Float64, additive_error::Bool )
  #stddev = normal_stddev()   # Standard deviation of mutational perturbations
  #println("mutate attributes  normal_stddev: ",normal_stddev)
  #attributes = min(1.0,max(0.0,attributes+normal_stddev*randn(length(attributes))))
  new_attributes = deepcopy(attributes)
  if additive_error
    for i = 1:length(new_attributes)
      #println("B attributes[",i,"]: ",new_attributes[i])
      new_attributes[i] += +normal_stddev*randn()
      if new_attributes[i] < 0
          new_attributes[i] += 1.0
          #println("wrapped up: ",new_attributes[i])
      end
      if new_attributes[i] > 1.0
          new_attributes[i] -= 1.0
          #println("wrapped down: ",new_attributes[i])
      end
      new_attributes[i] = min(1.0,max(0.0,new_attributes[i]))
      #println("A attributes[",i,"]: ",new_attributes[i])
    end
  else  # multiplicative copy error
    for i = 1:length(new_attributes)
      if new_attributes[i] <= 0.0
        #println("neg attribute: ",new_attributes[i])
        new_attributes[i] = 1.0e-6
      end
      multiplier = (1.0+normal_stddev*randn())
      #println("multiplier: ",multiplier)
      while multiplier <= 1.0e-6
        #println("neg multiplier")
        multiplier = (1.0+normal_stddev*randn())
      end
      new_attributes[i] *= multiplier
      if new_attributes[i] < 0.0
        #println("negative attribute with i=",i,": attribute: ",new_attributes[i])
      end
    end
  end
  #println("attributes: ",new_attributes)
  return new_attributes
end

# Changed to the "linear" model of innovation from the "quadratic" model on 2/14/18.
function innovate_attribute( attributes::Vector{Float64}, subpop_index::Int64, fitness_locations::Vector{SpatialEvolution.fitness_location_type} )
  j = rand(1:length(attributes))   # Choose a random attribute
  Bdiff = abs(attributes[j]-fitness_locations[subpop_index].ideal[j])
  #println("B  j: ",j,"  attribute: ",attributes[j],"  ideal: ",fitness_locations[subpop_index].ideal[j]," diff: ",Bdiff)
  #attributes[j] += rand()*abs(attributes[j] - fitness_locations[subpop_index].ideal[j])*(fitness_locations[subpop_index].ideal[j]-attributes[j])
  attributes[j] += rand()*(fitness_locations[subpop_index].ideal[j] - attributes[j])   # additive innovation
  #=
  r = rand()
  println("r: ",r,"  ratio: ",fitness_locations[subpop_index].ideal[j]/attributes[j])
  attributes[j] *= rand()*(fitness_locations[subpop_index].ideal[j]/attributes[j])   # multiplicative innovation
  =#
  Adiff = abs(attributes[j]-fitness_locations[subpop_index].ideal[j])
  #println("A  j: ",j,"  attribute: ",attributes[j],"  ideal: ",fitness_locations[subpop_index].ideal[j]," diff: ",Adiff)
  #println("Ddiff: ",Bdiff-Adiff)
  @assert(Bdiff-Adiff>0.0)
end 

@doc """ function initialize_fitness_locations()
  Sets up ideal value for each fitness location.
  There are 3 kinds of spatial fitness variation:
  1)  Random:  ideal is chosen randomly between sr.ideal_min and sr.ideal_max
  2)  Circular:  as one iterates through fit locations, ideal starts close to sr.ideal_min, then moves toward
      sr.ideal_max, then moves back to sr.ideal_min.
  3)  Extreme:  ideal is chosen to be within 0.5*sr.ideal_range of sr.ideal_min or sr.ideal_max
"""
function initialize_fitness_locations( sr::SpatialEvolution.spatial_run_result_type )
  fitness_locations = [ fitness_location_type( zeros(Float64,sr.num_attributes) ) for j = 1:sr.num_fit_locations ]
  if !sr.linear_variation && !sr.extreme_variation  # random variation---no relationship to subpop number
    #println("init sr.linear_variation: ",sr.linear_variation,"  sr.extreme_variation: ",sr.extreme_variation)
    for j = 1:sr.num_fit_locations
      for k = 1:sr.num_attributes
        if sr.ideal_min != sr.ideal_max
          fitness_locations[j].ideal[k] = sr.ideal_min+rand()*(sr.ideal_max-sr.ideal_min)
        else
          fitness_locations[j].ideal[k] = sr.ideal_min
        end
      end
    end
  elseif sr.linear_variation && !sr.extreme_variation
    increment = (sr.ideal_max-sr.ideal_min)/sr.num_fit_locations
    mid = Int(floor(sr.num_fit_locations/2))
    for j = 1:sr.num_fit_locations
      for k = 1:sr.num_attributes
        fitness_locations[j].ideal[k] = sr.ideal_min+increment*(j-1)
      end
    end
  elseif !sr.linear_variation && sr.extreme_variation  # randomly choose between low_value and high_value
    for j = 1:sr.num_fit_locations
      for k = 1:sr.num_attributes
        if rand() < 0.5
          fitness_locations[j].ideal[k] = sr.ideal_min
        else 
          fitness_locations[j].ideal[k] = sr.ideal_max
        end
      end
      #println("j: ",j,"  ideal: ",fitness_locations[j].ideal)
    end
  else
    error("combining linear variation and extreme variation in initialize_fitness_locations is not legal.")
  end
  return fitness_locations
end  

function print_fit_locations( fitness_locations::Vector{fitness_location_type}, sr::SpatialEvolution.spatial_result_type )
  for j = 1:sr.num_fit_locations
    for k = 1:sr.num_attributes
      @printf("j:%2d  k:%2d  ideal:%.3f\n",j,k,fitness_locations[j].ideal[k])
    end
  end
end
  
@doc """ horiz_transfer_linear!()
  Transfers variants between subpopulations in a linear fashion (either forward or backward).
  This corresponds to the stepping stone model of population structure from population genetics.
  Elements to be transfered are selected by proportional selection.
  Elements to be replaced can be random or selected by reverse proportional selection depending on the flag neg_select.
  subpops is modified by this function (as a side effect)
"""
function horiz_transfer_linear!( N::Int64, m::Int64, num_emigrants::Int64, subpops::PopList, id::Vector{Int64}, 
    variant_table::Dict{Int64,variant_type}, fitness_locations::Vector{SpatialEvolution.fitness_location_type}, fit_slope::Float64;
     forward::Bool=true, neg_select::Bool=true, emigrant_select::Bool=true, neutral::Bool=false )
  n = Int(floor(N/m))    # size of subpopulations
  num_attributes = length(variant_table[subpops[1][1]].attributes)
  num_fit_locations = length(fitness_locations)
  #println("ht num_fit_locations: ",num_fit_locations)
  #println("horiz_transfer_linear! forward: ",forward,"  m: ",m,"  num_attributes: ",num_attributes)
  emigrants = PopList()
  for j = 1:m
    if emigrant_select
      Base.push!( emigrants, propsel( subpops[j], num_emigrants, variant_table ) )
    else
      # TODO:  do random choice instead of first elements
      # Added shuffle on 1/23/18.  Not efficient, but should be correct.
      Base.push!( emigrants, Base.shuffle(subpops[j])[1:num_emigrants] )   # Neutral
    end
  end
  new_emigrants = Population[ Population() for j = 1:m ]
  for j = 1:m
    #println("j: ",j,"  j%m+1: ",j%m+1,"  (j+m-2)%m+1: ",(j+m-2)%m+1)
    # subpop k is the source, subpop j is the destination.  k == 0 means no transfer
    if forward
      k = j > 1 ? j-1 : 0
    else
      k = j < m ? j+1 : 0
    end
    #println("j: ",j,"  k: ",k)
    # Create new variants for the emigrants in the new subpop
    if k > 0
      for e in emigrants[k]   # subpop k is the source, subpop j is the destination
        i = id[1]
        #println("e: ",e,"  i: ",i)
        #println("new emigrant i: ",i,"  subpop_index:",k,"  num_attributes: ",num_attributes )
        variant_table[i] = deepcopy(variant_table[e])
        ii = rand(1:n)  # Choose a random index within the subpopulation
        fit_loc_ind = fit_loc_index(N,m,num_fit_locations,j,ii)
        variant_table[i].fitness_location = fit_loc_ind   # set the new fitness location
        variant_table[i].fitness = fitness( variant_table[i].attributes, fitness_locations[fit_loc_ind].ideal, neutral, fit_slope )  
        #variant_table[i] = variant_type( i, 0.0, j, emigrants[j].attributes  )
        #println("variant_table[",e,"]: ",variant_table[e])
        #println("variant_table[",i,"]: ",variant_table[i])
        Base.push!( new_emigrants[j], i )
        id[1] += 1
      end
    end
  end
  for j = 1:m
    if forward
      k = j > 1 ? j-1 : 0
    else
      k = j < m ? j+1 : 0
    end
    if k > 0
      pop_after_deletion = Population[]
      #println("j: ",j,"  j%m+1: ",j%m+1,"  (j+m-2)%m+1: ",(j+m-2)%m+1)
      if neg_select  # use reverse proportional selection to delete elements by negative fitness
        pop_after_deletion = reverse_propsel(subpops[j],num_emigrants,variant_table)
      else  # delete random elements to delete
        # TODO:  Add shuffle so that elements to be deleted are random instead of arbitrary.
        pop_after_deletion = subpops[j][1:(n-num_emigrants)]
      end
      subpops[j] = append!( pop_after_deletion, new_emigrants[j] )
    end
  end
  emigrants  # perhaps should be the modified subpops
end

function print_subpop( subpop::Vector{Int64}, variant_table::Dict{Int64,variant_type} )
  "[ $(join([ @sprintf(" %5d:%5.4f",vt,variant_table[vt].fitness) for vt in subpop ]))]"
end

function print_pop( stream::IO, subpops::PopList, variant_table::Dict{Int64,variant_type} )
  for sp in subpops
    print(stream,print_subpop(sp,variant_table))
  end
  println(stream)
end

# compute and save statistics about subpopulations and populations

function means( subpops::PopList, variant_table::Dict{Int64,variant_type} )
  fit(v) = variant_table[v].fitness
  means = [ mean(map(fit,s)) for s in subpops ]
  vars = [ var(map(fit,s)) for s in subpops ]
  return means, vars
end

function attr_vars( subpops::PopList, variant_table::Dict{Int64,variant_type}, num_attributes::Int64 )
  #println("attr_vars: num_attributes: ",num_attributes)
  #=
  for s in subpops
    println("subpop: ",s)
    println(s," fitness: ",[variant_table[v].fitness for v in s ],"  variance: ",var([variant_table[v].fitness for v in s ]))
    for j = 1:num_attributes
      println("attribute[",j,"]: ",[(v,variant_table[v].attributes[j]) for v in s],"  variance: ",var([variant_table[v].attributes[j] for v in s]) )
    end
  end
  =#
  ave_vars = zeros(Float64,length(subpops))
  i = 1
  for s in subpops
    att_vars = [ var([variant_table[v].attributes[j] for v in s]) for j =1:num_attributes]
    #println(s," att_vars: ",att_vars)
    ave_vars[i] = mean(att_vars)
    i += 1
  end
  #println("ave_vars: ",ave_vars)
  return ave_vars
end

function attr_coef_vars( subpops::PopList, variant_table::Dict{Int64,variant_type}, num_attributes::Int64 )
  #println("attr_vars: num_attributes: ",num_attributes)
  avg_coef_vars = zeros(Float64,length(subpops))
  i = 1
  for s in subpops
    att_coef_vars = [ coef_var([variant_table[v].attributes[j] for v in s]) for j =1:num_attributes]
    #println(s," att_coef_vars: ",att_coef_vars)
    avg_coef_vars[i] = mean(att_coef_vars)
    i += 1
  end
  #println("avg_coef_vars: ",avg_coef_vars)
  return avg_coef_vars
end

function fit_loc_index(N,num_subpops,num_fit_locs,j,i)
  n = Int(ceil(N/num_subpops))
  mult = Int(ceil(num_fit_locs/num_subpops))
  div = Int(ceil(n*num_subpops/num_fit_locs))
  #println("fit_loc_index num_subpops: ",num_subpops,"  num_fit_locs: ",num_fit_locs,"  j: ",j,"  i: ",i,"  result: ",mult*(j-1) + Int(floor((i-1)/div))+1)
  return mult*(j-1) + Int(floor((i-1)/div))+1
end

function clean_up_variant_table( previous_variant_id::Int64, previous_previous_variant_id::Int64,
    variant_table::Dict{Int64,variant_type} )
  #println("clean up:  ppv: ",previous_previous_variant_id,"  pv: ",previous_variant_id)
  for v = previous_variant_id:previous_previous_variant_id-1
    delete!(variant_table,v)
  end
end
 
function coef_var( lst )
  return std(lst)/mean(lst)
end

