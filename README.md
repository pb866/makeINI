Perl scripts makedepos.pl and makeemiss.pl
==========================================

Purpose
-------

Auxiliary scripts for the box model _DSMACC_
(https://github.com/pb866/DSMACC-testing.git) to generate _KPP_ files
with emission and deposition rates from data files. The scripts translate
emission and deposition data that is arranged in columns with species
names and rate data separated by whitespaces to _KPP_ language that can be
interpreted by the box model _DSMACC_. Only the data are treated for
species that are part of the current mechanism. For deposition velocities,
you can specify to apply a standard deposition rate to all species for
which no predefined values exist.


Running the script
------------------

### Shell commands

The scripts can be run by themselves or with make within the model _DSMACC_
(https://github.com/pb866/DSMACC-testing.git). To run by themselves use:

```
perl makeemiss.pl [<list of kpp input files.> [<data file>]]
perl makedepos.pl [<list of kpp input files.> [<data file> [<flag for standard>]]]
```

All parameter are optional, if you want to assign the second or third
argument, you need to assign the arguments before as well. If arguments
are obsolete, standard values will be assigned.


### Script arguments and input data

#### KPP input files

The scripts check for emission and deposition data, whether the species
are actually part of the current mechanism (as otherwise _KPP_ will crash). Therefore, all _KPP_ files (and relative or absolute folder paths)
of the current mechanism need to be specified in the first script argument.
Files need to specified with the names of the _KPP_ files without the file
endings '.kpp' as a list separated by whitespaces wrapped in quotes. The
standard names in both files are defined as:

```
"inorganic organic"
```


#### Data file

The actual emission and deposition data to be included in the scenario
are saved in text files. Standard paths/names are `../InitCons/emiss.dat`
and `../InitCons/depos.dat`.
Any other name can be specified in the 2nd script argument.  
The format is:

```
# Line comments started by '#'
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

If no emission or deposition data is desired, you can set the second
script argument to `0` or `-`. Alternatively, you can delete the data
files. If a data file is not found or the 2nd argument is set to `0`
or `-`, an empty KPP file with a few sample comments is generated, which
is needed for a proper compilation of the _DSMACC_ box model.



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

The scipts produce _KPP_ files with the standard names `depos.kpp` and
`emiss.kpp`. File names are hard coded and need to be changed in the
script. Include the _KPP_ code in your master _KPP_ file and run _KPP_
to use the emission and deposition rates in your model runs.


Links to _DSMACC_
-----------------

The script is designed for the _DSMACC_ version available on [github](https://github.com/pb866/DSMACC-testing.git). Place the scripts
`makeemiss.pl` and `makedepos.pl` in your mechanisms folder together with
your _KPP_ mechanism files. Place the data files in your _InitCons_ folder.
Add or change the include commands in `src/model.kpp` to include the
generated kpp files in your mechanism and generate the mechanism with
`make kpp.`

Alternatively, to running each script with perl individallyfor emissions
and depositions, you can create both scripts in one go by running
`make ini` in your main folder. If you want to pass over arguments to the
script, use the respective make variables `FKPP, FDEP, FEMI, and FSTD`:

```
make ini FDEP=<deposition data file> FEMI=<emission data file> FKPP=<"list of KPP input files"> FSTD=<switch for standard vd>
```

Alternatively, to changing standard values of the script in the source code,
you can define new standard values in the Makefile (see commented section
at the top):

```
FDEP ?= 'depos.dat'         # data file variable for makedepos script
FEMI ?= 'emiss.dat'         # data file variable for makedepos script
FKPP ?= 'inorganic organic' # kpp input file variable for makedepos scrpit
FSTD  ?= 1                  # option to extend standard vd to all species
export FDEP, FEMI, FKPP, FSTD
```
