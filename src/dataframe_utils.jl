# Analyze a spatial simulation output file
using CSV, DataFrames
export read_csv, summarize_evar, build_dataframe_from_type, add_row_to_dataframe

# Sample call: 
# summarize_evar(read_csv("../data/2_1_18/evar_N64_na1_ne0_hzboth_std0.05.A.csv"),extreme_variation=false,circular_variation=true,use_fit_locations=true)

function read_csv( filename::AbstractString )
  println("filename: ",filename)
  readtable(filename,allowcomments=true,commentmark='#')
end

function summarize_evar( evar::DataFrame; circular_variation::Bool=true, extreme_variation::Bool=true, use_fit_locations::Bool=true )
  # In the next line, the list gives the fields that will be split in the returned dataframe.  If there is only one value for that field, it will be included.
  #sum_evar=by(evar,[:N,:num_emigrants,:num_attributes,:num_subpops,:use_fit_locations,:circular_variation,:extreme_variation]) do df
  sum_evar=by(evar,[:N,:num_attributes,:num_subpops,:use_fit_locations,:circular_variation,:extreme_variation]) do df
    # The mean function will be applied to each of the fields in this list.
        DataFrame(mean_fit=mean(df[:fitness_mean]),attr_var=mean(df[:attribute_variance]))
      end
  # This restricts the rows in the returned data frame.
  sum_evar[(sum_evar[:circular_variation].==circular_variation).&(sum_evar[:extreme_variation].==extreme_variation).&(sum_evar[:use_fit_locations].==use_fit_locations),:]
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
