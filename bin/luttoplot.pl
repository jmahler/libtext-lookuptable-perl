#!/usr/bin/perl
use strict;

use Text::LookUpTable;

my $usage = "luttoplot.pl <file> [<type>]\n" .
		 	"  <type> := R\n".
			"  Produces output on STDOUT\n";

die $usage unless (@ARGV >= 1);

my $file = shift @ARGV;

my $type = 'R';
if (@ARGV) {
	$type = shift @ARGV;
}

my $tbl = Text::LookUpTable->load_file($file)
	or die "Unable to load table from file: $!\n";

print $tbl->as_plot($type);
