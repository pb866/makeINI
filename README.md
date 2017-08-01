Perl scripts makedepos.pl and makeemiss.pl
==========================================

Purpose
-------

Auxiliary scripts for the box model
[_DSMACC_](https://github.com/pb866/DSMACC-testing.git) to generate _KPP_ files
with emission and deposition rates from data files. The scripts translate
emission and deposition data that is arranged in columns with species names and
rate data separated by whitespaces to _KPP_ language that can be interpreted by
the box model _DSMACC_. Only the data are treated for species that are part of
the current mechanism. For deposition rates, you can specify to apply a
standard deposition rate to all species for which no predefined values exist.

Running the script
------------------

### Shell commands

The scripts can be run by themselves or with make within the model _DSMACC_
(https://github.com/pb866/DSMACC-testing.git). To run by themselves use:

```
perl makeemiss.pl [<list of kpp input files.> [<data file> [<kpp output file>]]]
perl makedepos.pl [<list of kpp input files.> [<data file> [<kpp output file> [<flag for standard>]]]]
```

All parameter are optional, if you want to assign the second or third
argument, you need to assign the arguments before as well. If arguments
are obsolete, standard values will be assigned.


### Script arguments and input data

#### KPP input files

The scripts check for emission and deposition data, whether the species
are actually part of the current mechanism (as otherwise _KPP_ will crash).
Therefore, all _KPP_ files of the current mechanism need to be specified in the
first script argument. Files need to specified with the names of the _KPP_
files without the file endings '.kpp' and the folder paths `./mechanisms/` as a
list separated by whitespaces wrapped in quotes. The standard names in both
files are defined as:

 ```
"inorganic organic"
```


#### Data files

The actual emission and deposition data to be included in the scenario
are saved in text files. The script will stop, if this parameter is empty.
The format of the data files is:

```shell
# Comments started by '#'
<column 1> <whitespace separator(s)> <column 1>
species names   emission/deposition rate # inline comment
DEPOS           <standard vd>
```

Data files consists of 2 columns separated by whitespace. The first column
holds the _MCM_ species names, the second column the emission or deposition
rate in s<sup>-1</sup> in _FORTRAN_ format, i.e. `X.XXD±XX`. Comments can
be added as line comments or at the end of the data with an initial `#`.

In the deposition data a standard value can be defined, which is then
extended to all species in the mechanism except for those with definitions
already in the data file. The key word for the standard value is `DEPOS`
as species name followed by the value of the standard _v<sub>d</sub>_
in the second column. If no value is assigned, but the option to extend
a standard value to all species is used (see next section), the script
assigns a _standard v<sub>d</sub>_ of `5.00d-6`.


#### KPP output files

The third programme argument defines the folder paths and name of the output kpp
file. A default file will be generated in the mechanisms folder, if the argument
is empty with the name of the data file preceeded by `emiss_` or `depos` and the
file ending `kpp`.

Default name:
```
./mechanisms/[emiss/depos]_<data file name>.kpp
```


#### Standard depositon rate

In _makedepos.pl_, a standard deposition rate can be assigned, which is
assigned to every species in the mechanism (derived from the input _KPP_
files) that has no predefined deposition velocity. The script uses a
_standard v<sub>d</sub>_ of `5.00d-6`, but any other value can be assigned
in the input data file using the keyword `DEPOS` to assign the standard
rate.
If you only want to use the measured emission values in your data file,
assign a `0` to the 3rd script argument. The standard value is `1`, which
means the assignment of the standard deposition velocity.


Script output
-------------

The scipts produce _KPP_ files with the [above](#kpp-output-files) default names.
Include the _KPP_ code in your master _KPP_ file or during `make kpp` and run
_KPP_ to use the emission and deposition rates in your model runs.


Links to _DSMACC_
-----------------

The script is designed for the _DSMACC_ version available on
[github](https://github.com/pb866/DSMACC-testing.git). Place the scripts
`makeemiss.pl` and `makedepos.pl` in `./src/background/` together with
your _KPP_ mechanism files in `./mechanisms/`. Place the data files in your
`InitCons` folder. Run `make kpp` and follow the on-screen instructions.


Julia scripts makeEMISS.jl / makeDEPOS.jl
=========================================

The perl scripts have been re-written in julialang. The functionalities stay the
same as for the perl script with refined on-screen warning messages and additional
information about the scripts used and the date/time generated in the output file.

Call files using the same arguments/rules as defined [above](#shell commands):

```shell
julia makeEMISS.jl [ARGS]
julia makeDEPOS.jl [ARGS]
```



Version history
===============

v2.0
----
- Scripts re-written in julialang (julia 0.6.0)
- Refined on-screen warnings about missing files and missing species in the
  mechanism
- Additional information about script version and date/time generated in the
  output kpp files

v1.3
----
- Revised folder paths, so script is called from _DSMACC_ main folder
- New script argument for KPP output file name
- Default KPP output file: `./mechanisms/[emiss/depos]\_<data file name>.kpp`
- No default data file name, script stops, if argument is empty of file doesn't exist

v1.2.2
------
- Updated README

v1.2.1
------
- Fix in assignment of _v<sub>d</sub>_ that allows only the assignment of
  _v<sub>d</sub>_ without any further definitions

v1.2
----
- Omission of perl modules
- Additional warnings for empty output files

v1.1
----
- Generation of empty kpp output files, if second argument is `0` or `-`
  or data file doesn't exist
- On-screen warnings

v1.0
----
- First working version
- Predefined _v<sub>d</sub>_
- Script arguments for KPP files and data file
- Switch to extend standard _v<sub>d</sub>_ or use predefined values only
