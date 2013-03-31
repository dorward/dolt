#!/usr/bin/perl -w

# Change Log

# 31 March 2013
# Move to Github

# 26 Sep 2001
# Code clean up

# Sep 2001
# Dolt 2 release

# The dolt

# Script to generate webpages with reusable content
# and use different styles for sites.

# Created by David Dorward
# Latest version: http://dorward.me.uk/

# Lets avoid confusion with variables
use strict;

# We need to get command line parameters, the Getopt module and
# command will to the trick. A : indicates that an argument is
# required.
use Getopt::Std;
getopts("s:o:i:l:q");

# Define any global variables:
my $version = "3";
my $creationdate = "March 2013";

# Now lets make it clear where the output of the program begins on
# screen, but only if quiet mode is off. By making use of $main::opt_q
# here we also avoid a error caused by only otherwise having it in the
# script once, and using strict (Perl asks if it could be a type and
# that is worrying for the end user.
if (!$main::opt_q){
  print "\n";
}

# Open the directories and file handles needed and do some error
# checking. We need to make sure that the correct command line
# parameters have been passed and that they are valid.

if ($main::opt_s) {
opendir(HTML_DIR_IN,"$main::opt_s") || die "\nCannot open directroy $main::opt_s, make sure that is exists and you have permission to read from it.\n \nThe Perl Interpreter gives this error: $!" ;
} else {
  help_output("You have not provided a HTML source directory");
}

if ($main::opt_i) {
opendir(INCLUDE_DIR_IN,"$main::opt_i") || die "\nCannot open directroy $main::opt_i, make sure that is exists and you have permission to read from it.\n \nThe Perl Interpreter gives this error: $!" ;
} else {
  help_output("You have not provided an include source directory");
}

if ($main::opt_o) {
opendir(HTML_DIR_OUT,"$main::opt_o") || die "\nCannot open directroy $main::opt_o, make sure that is exists and you have permission to write to it.\n \nThe Perl Interpreter gives this error: $!" ;
} else {
  help_output("You have not provided an output directory");
}

if ($main::opt_l) {
  open(LOGFILE,">>$main::opt_l") || die  "\nCannot open or create file $main::opt_l, make sure that you have permission to write to it.\n \nThe Perl Interpreter gives this error: $!" ;
} else {
  information_output("(No log file)");
}

# OK, now we will just print out some basic information about the
# program.
information_output("***\nDOLT Version: $version\nCreated by David Dorward\n$creationdate\n***");

# Next we will date stamp the run (for the benefit of the log file if
# it is being used.
 
use Time::localtime;
my $tm = localtime;
(my $DAY, my $MONTH, my $YEAR, my $hour, my $minute) = ($tm->mday, $tm->mon, $tm->year, $tm->hour, $tm->min);
$MONTH = $MONTH + 1;
$YEAR = $YEAR + 1900;
information_output("This run on $DAY-$MONTH-$YEAR \@ $hour.$minute");

# To start we need a list of all the files in the HTML input
# directory. So grep the from the directory listing, close the
# directory, and list the files to the outputs.
my @INPUT_FILES=grep(/\.html$/i, readdir HTML_DIR_IN);
closedir(HTML_DIR_IN);
information_output("Will process the following files:");
foreach my $file (@INPUT_FILES) {
  information_output($file);
}

# Now we need to run through each file in turn
foreach my $r (@INPUT_FILES) {
  # Open the output file for writing.
  open (WEBPAGE,">$main::opt_o/$r");
  information_output("Starting work on" . $r);
  # Open the input file for reading
  open(INPUTFILE,"$main::opt_s/$r") || die "Error $r not found";
  my @inputfile = <INPUTFILE>;
  # Run through the input file
  foreach $a (@inputfile) {
    chomp ($a);
    # Check to see if it is a dolt command line
    if ($a =~ /<!--\*.*[a-zA-Z0-9]*.*\*-->/) {
      # If it is that clear out the rubbish to get the file name itself.
      my $fileToInsert = $a;
      $fileToInsert =~ s/<!--\s*\*\s*//;
      $fileToInsert =~ s/\s*\*\s*-->//;
      # Explain what your doing
      information_output("Inserting $fileToInsert into $r");
      # Open the file for reading
      open(INSERT,"$main::opt_i/$fileToInsert") || die "Error $fileToInsert: file not found\n";
      my @INSERTER = <INSERT>;
      close(INSERT);
      # Run through each line and output it to the file
      foreach my $y (@INSERTER) {
	print WEBPAGE $y;
      }
    } else {
      print WEBPAGE "$a\n";
    }
  }
  close(WEBPAGE);
  information_output("File finished.");
}

# OK thats everything, we will now just output an end of run message
# close all the file handles and exit. The rest of the script file is
# made up from subroutines which are called earlier in the program.
information_output("The dolt has finished processing\n***\n");
close(LOGFILE);
close(INCLUDE_DIR_IN);
close(HTML_DIR_OUT);
exit;


# This subroutine is displayed if there is something wrong with
# command line parameters. It displays the correcy syntax for the
# command line.
sub help_output {
print $_[0] . "\n";
print "\n  usage: dolt -s {dir} -i {dir} -o {dir} [-q -l {file}]\n";
print "options: -s [dir]  : Directory containing HTML source files\n";
print "         -i [dir]  : Directory containing files to include\n";
print "         -o [dir]  : Directory to output files to\n";
print "         -l [file] : Log file to record to (if wanted)\n";
print "         -q        : Turn quiet mode on (suppress screen output)\n";
print "         -i and -s may be the same directory\n\n";
print "Save yourself time. Create a shell script or batch file to issue the dolt command.\n\n";
exit;
}

# This subroutine handles the output to both the log and screen if
# wanted.
sub information_output {
  # If using a log file record to log file
  if ($main::opt_l) {
    print LOGFILE $_[0] . "\n";
  }
  # If using quiet mode, don't output to screen.
  if (!$main::opt_q) {
    print $_[0] . "\n";
  }
}
