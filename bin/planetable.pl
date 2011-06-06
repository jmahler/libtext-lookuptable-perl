#!/usr/bin/perl
use strict;

use Text::LookUpTable;

my $usage = "planetable.pl <table file> <a> <b> <c> [<round digits>]\n" .
			"\n".
			"  Change the values of the table in the file\n".
			"  with the function for a plane with constants\n".
			"  a, b, and c (z = a*y + b*x + c)\n".
			"\n".
			"  <round digits> is the number of digits\n".
			"  to keep after the decimal place.\n";

die $usage unless (@ARGV == 4 or @ARGV == 5);

my $file = shift @ARGV;
my $a = shift @ARGV;
my $b = shift @ARGV;
my $c = shift @ARGV;

my $r = 2;
if (@ARGV) {
	$r = shift @ARGV;
}
$r = 10**$r;

my $tbl = Text::LookUpTable->load_file($file)
	or die "Unable to load table from file: $!\n";

my @xc = $tbl->get_x_coords();
my @yc = $tbl->get_y_coords();
my $num_x = @xc;
my $num_y = @yc;

@yc = reverse @yc;

for (my $x = 0; $x < $num_x; $x++) {
	for (my $y = 0; $y < $num_y; $y++) {
		my $val = $tbl->get($x, $y);

		# calculate new value
		$val = $a * $yc[$y] + $b * $xc[$x] + $c;
		$val = (int($val * $r)) / $r;  # round

		$tbl->set($x, $y, $val);
	}
}

$tbl->save_file();
