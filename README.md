# spatial
Spatially varying environment cultural evolution simuation.
The source code files are in the src subfolder.
Examples are in the src/examples/ subfolder.

Example command line run from the src subfolder:
$ julia run.jl examples/example1 1

Here, examples/example1.jl  is the configuration file containing parameter settings,
and 1 is the random number seed.  The output file is the CSV file: examples/example1.csv.
Multiple cores can be used by means of the Julia "-p" option.  For example:
$ julia -p 4 run.jl examples/example1
Under this option, using the random number seed does not give repeatable results.

The output CSV file includes the parameter settings as comments preceded by the # symbol.
There is one output row per simulation trial.

There is a separate optional program which will average results over trials.  For example:
$ julia average_over_trails.jl examples/example1
The produces an output file  examples/example1_mean.csv.



