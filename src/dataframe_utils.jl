# Analyze a spatial simulation output file
using CSV, DataFrames
export read_csv, summarize_spatial, build_dataframe_from_type, add_row_to_dataframe, average_over_trials, params_from_fixed_fields,
    fixed_nonfixed_fields, sumarize_spatial, average_over_trials, average_file_over_trials

# Sample call: 
# summarize_evar(read_csv("../data/2_1_18/evar_N64_na1_ne0_hzboth_std0.05.A.csv"),extreme_variation=false,linear_variation=true,use_fit_locations=true)

function read_csv( filename::AbstractString )
  println("filename: ",filename)
  readtable(filename,allowcomments=true,commentmark='#')
end


function read_params( filename::AbstractString )
  lines = []
  open(filename) do f
    while !eof(f)
      line = readline(f)
      if line[1] == '#'
        Base.push!(lines,line)
      else
        break
      end
    end
  end
  lines
end

function params_from_fixed_fields( df::DataFrame )
  fixed_param_list = AbstractString[]
  nonfixed_param_list = Symbol[]
  for f in names(df)
    u = unique(df[f])
    if length(u) > 1
      Base.push!(nonfixed_param_list,f)
    else
      Base.push!(fixed_param_list,"# $f = $(u[1])")
    end
  end
  fixed_param_list, nonfixed_param_list
end

function fixed_nonfixed_fields( df::DataFrame )
  fixed_param_list = Symbol[]
  nonfixed_param_list = Symbol[]
  for f in names(df)
    u = unique(df[f])
    if length(u) > 1
      Base.push!(nonfixed_param_list,f)
    else
      Base.push!(fixed_param_list,f)
    end
  end
  fixed_param_list, nonfixed_param_list
end


BoolInt = Union{Bool,Int64}

# Summarize the spatial results spreadsheet.
# For all of the keyword arguments, a value of -1 means that the corresponding field will be unrestricted.
# For Int arguments, a positive value means means that the corresponding field is restricted to be that value
# For BoolInt arguments, a value of true or false means that the corresponding field is restricted to be that value
function summarize_spatial( evar::DataFrame; linear_variation::BoolInt=false, extreme_variation::BoolInt=true, use_fit_locations::BoolInt=true, patchy::BoolInt=false,
      horiz_select::BoolInt=false, num_emmigrants::Int64=0, num_attributes::Int64=1 )
  # In the next line, the list gives the fields that will be split in the returned dataframe.  If there is only one value for that field, it will be included.
  spat_df=by(evar,[:N,:horiz_select,:num_subpops,:use_fit_locations,:linear_variation,:extreme_variation,:patchy,
        :num_emmigrants,:num_attributes,:num_fit_locations,:int_burn_in,:ideal_max,:ideal_min,:ideal_range]) do df
    # The mean function will be applied to each of the fields in this list.
        DataFrame(mean_fit=mean(df[:fitness_mean]),fit_var=mean(df[:fitness_variance]),
            attr_var=mean(df[:attribute_variance]),attr_coef_var=mean(df[:attribute_coef_var]))
      end
  # This restricts the rows in the returned data frame.
  filtr = fill(true,size(spat_df)[1])
  (linear_variation != -1) &&  (filtr .&= (spat_df[:linear_variation].==linear_variation))
  (extreme_variation != -1) && (filtr .&= (spat_df[:extreme_variation].==extreme_variation))
  (use_fit_locations != -1) && (filtr .&= (spat_df[:use_fit_locations].==use_fit_locations))
  (horiz_select != -1) && (filtr .&= (spat_df[:horiz_select].==horiz_select))
  (patchy != -1) && (filtr .&= (spat_df[:patchy].==patchy))
  (num_emmigrants != -1) && (filtr .&= (spat_df[:num_emmigrants].==num_emmigrants))
  (num_attributes != -1) && (filtr .&= (spat_df[:num_attributes].==num_attributes))
  spat_df[filtr,:]
end

function average_over_trials( df::DataFrame, mean_fields::Vector{Symbol} )
  # In the next line, the list gives the fields that will be split in the returned dataframe.  If there is only one value for that field, it will be included.
  #mean_fields = [:fitness_mean,:fitness_variance,:attribute_variance,:attribute_coef_var]
  fixed, nonfixed = fixed_nonfixed_fields( df )
  println("fixed: ",fixed)
  println("nonfixed: ",nonfixed)
  #fixed_elements = [:num_trials, :ideal_max, :ideal_min, :neutral, :mu, :ngens, :normal_stddev, :fit_slope, :additive_error,
  #    :fitness_mean, :fitness_variance, :attribute_variance, :attribute_coef_var ]
  #filter!(x->!(x in fixed_elements), fields )  # remove fixed and averaged fields
  nfixed = filter(x->!(x in mean_fields),nonfixed)  # remove mean fields from nonfixed
  println("nfixed: ",nfixed)
  ddf = delete!(copy(df),fixed)   # remove fixed fields from df
  #=
  spat_df=by(df,nonfixed) do df
    DataFrame(mean_fit=mean(df[:fitness_mean]),fit_var=mean(df[:fitness_variance]), attr_var=mean(df[:attribute_variance]),attr_coef_var=mean(df[:attribute_coef_var]))
  end
  spat_df
  =#
  aggregate( ddf, nfixed, mean )
end

function average_file_over_trials( filename::AbstractString, mean_fields::Vector{Symbol} )
  param_lines = read_params( filename )
  indf = read_csv( filename )
  pstrings, non_fixed = params_from_fixed_fields( indf )
  outdf = average_over_trials( indf, mean_fields )
  out_filename = filename[1:end-4] * "_means" * filename[end-3:end]
  open(out_filename, "w" ) do f
    write(f, join(pstrings,"\n"),"\n",join(param_lines,"\n"),"\n")
    write(f, join(map(string,names(outdf)),","),"\n")
  end
  CSV.write(out_filename,outdf,append=true)
end

# Construct a dataframe from a composite type whose columns have the types of the fields of the composite type
function build_dataframe_from_type( typename::DataType, length::Int64 )
  type_types = typename.types
  df = DataFrame()
  i = 1
  for n in fieldnames(typename)
    df[n] = zeros(type_types[i],length)
    i += 1
  end
  df
end
    
#  r   is a struct with multiple fields whose types are the same as the types of the columns of DataFrame  df.
#  Modify row  i  of df to have values taken from the corresponding fields of  r.
#  Will give a bounds error if index is greater than size(df)[1].
function add_row_to_dataframe( df::DataFrame, record::Any, index::Int64 )
  for n in fieldnames(typeof(record))
    df[n][index] = getfield(record,n)
  end
end
  
function remove_elements( field_list::Array{Symbol,1}, remove_list::Array{Symbol,1} )
  filter(e->!(e in remove_list),field_list)
end
