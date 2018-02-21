# Analyze a spatial simulation output file
using CSV, DataFrames
export read_csv, summarize_evar, build_dataframe_from_type, add_row_to_dataframe

# Sample call: 
# summarize_evar(read_csv("../data/2_1_18/evar_N64_na1_ne0_hzboth_std0.05.A.csv"),extreme_variation=false,circular_variation=true,use_fit_locations=true)

function read_csv( filename::AbstractString )
  println("filename: ",filename)
  readtable(filename,allowcomments=true,commentmark='#')
end

BoolInt = Union{Bool,Int64}

# Summarize the spatial results spreadsheet.
# For all of the keyword arguments, a value of -1 means that the corresponding field will be unrestricted.
# For Int arguments, a positive value means means that the corresponding field is restricted to be that value
# For BoolInt arguments, a value of true or false means that the corresponding field is restricted to be that value
function summarize_spatial( evar::DataFrame; circular_variation::BoolInt=false, extreme_variation::BoolInt=true, use_fit_locations::BoolInt=true, patchy::BoolInt=false,
      horiz_select::BoolInt=false, num_emmigrants::Int64=0, num_attributes::Int64=1 )
  # In the next line, the list gives the fields that will be split in the returned dataframe.  If there is only one value for that field, it will be included.
  spat_df=by(evar,[:N,:horiz_select,:num_subpops,:use_fit_locations,:circular_variation,:extreme_variation,:patchy,
        :num_emmigrants,:num_attributes,:num_fit_locations,:int_burn_in,:ideal_max,:ideal_min,:ideal_range]) do df
    # The mean function will be applied to each of the fields in this list.
        DataFrame(mean_fit=mean(df[:fitness_mean]),fit_var=mean(df[:fitness_variance]),
            attr_var=mean(df[:attribute_variance]),attr_coef_var=mean(df[:attribute_coef_var]))
      end
  # This restricts the rows in the returned data frame.
  filtr = fill(true,size(spat_df)[1])
  (circular_variation != -1) &&  (filtr .&= (spat_df[:circular_variation].==circular_variation))
  (extreme_variation != -1) && (filtr .&= (spat_df[:extreme_variation].==extreme_variation))
  (use_fit_locations != -1) && (filtr .&= (spat_df[:use_fit_locations].==use_fit_locations))
  (horiz_select != -1) && (filtr .&= (spat_df[:horiz_select].==horiz_select))
  (patchy != -1) && (filtr .&= (spat_df[:patchy].==patchy))
  (num_emmigrants != -1) && (filtr .&= (spat_df[:num_emmigrants].==num_emmigrants))
  (num_attributes != -1) && (filtr .&= (spat_df[:num_attributes].==num_attributes))
  spat_df[filtr,:]
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
