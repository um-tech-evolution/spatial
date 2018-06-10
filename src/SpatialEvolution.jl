module SpatialEvolution
try  # For julia v7
  using Random
  using Distributed
catch
end
try
  using Dates
catch
end

include("types.jl")
include("propsel.jl")
include("spatial.jl")
#include("stash/spatial8_24_17.jl")
include("run_spatial.jl")
end

using Main.SpatialEvolution
