#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(first_index); # to find first index of an entry in a list

### Variable declarations
## Data arrays and variables
my @dspc;     # species with predefined deposition velocities
my @vd;       # deposition velocities
my $mspc;     # species used in current mechanism
my $vdstd;    # standard deposition velocitiy
              # (defined with key word "DEPOS" in depos.dat)
my $num= -1 ; # counter for reaction labels in output file

## Temporary auxiliary arrays/variables
#  @lines:  lines read in from input file
#  @spl:    array with separated species and vd from input line
#  $idx:    index of current species in species/vd array

## file handling
#  $dfil:      data file "depos.dat" with predefined deposition velocities
#  $writefile: output KPP file "depos.kpp"
#  $file:      input KPP files with definitions of species
#              used in current mechanism

########################################################################

# Read in species and definitions of deposition velocities (vd)
# from data file "depos.dat"
open (my $dfil, '<', "depos.dat") or die "Could not open file $!";
chomp(my @lines = <$dfil>);
close($dfil);

# Split array of input lines into array of species names and vd
# unless it is an empty line or comment line starting with '#'
foreach (@lines) {
  if ($_ !~ /^\s*#/ && $_ !~ /^\s*$/) {
    $_ =~ s/^\s+//;
    print "$_\n";
    my @spl = split(/\s+/, $_);
    push @dspc, $spl[0];
    push @vd, $spl[1];
} }

# Find standard value and save to vdstd.
# If no standard value is defined in input file, use 5.00d-6.
my $idx = first_index { $_ eq "DEPOS" } @dspc;
if ($idx > 0) {
  $vdstd = $vd[$idx];
} else {
  $vdstd = "5.00d-6"
}

print "vd(standard): ",$vdstd, "\n" ;

########################################################################

# Open output file and set KPP EQUATIONS variable
open(my $writefile, ">","depos.kpp") or die "Could not open file  $!";
print $writefile "#EQUATIONS\n";

# Loop over KPP files
for my $file ('inorganic','organic') {
  open( FILE, "<$file.kpp" )  or die("Couldn't open :$!\\n");
# Find lines with species definitions
  while (<FILE>) {
    if (/.*\=\s*IGNORE.*/) {
# Increase counter
      $num += 1 ;
# Get species and store in $mspc
      s/\s*(\w)\s*\=\s*IGNORE.*/$1/g ;
      $mspc = $_ ;
      chomp $mspc ;

# Define experimental values:
      if (grep(/^$mspc$/, @dspc)) {
        $idx = first_index { $_ eq $mspc } @dspc;
        print $writefile
        "\{$num\.\} $mspc = DUMMY :  DEPOS*\($vd[$idx]\) ;\n" ;
# Otherwise use standard value:
      } else {
        $idx = first_index { $_ eq $mspc } @dspc;
        print $writefile
        "\{$num\.\} $mspc = DUMMY :  DEPOS*\($vdstd\) ;\n"
        if $mspc !~ /EMISS/;
  } } }

# Close all files
    close(FILE);
}
close($writefile);

########################################################################
