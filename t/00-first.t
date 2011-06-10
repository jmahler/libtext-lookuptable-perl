#!perl -w
use strict;
use warnings;

use Test::More tests => 84;

use_ok('Text::LookUpTable');

# {{{ some basic checks; load
my $str_start = 
"
                     rpm

               [1.25]  [3.35]  [4.97]  [5.66]
       [100]   1       2       3       4     
 map   [200]   2       2       4       5     
       [300]   10      -10     13      15    
       [400]   10      -10     13      12

";

my $lut = Text::LookUpTable->load($str_start);
ok($lut);

my $str_tbl = $lut;
ok($str_tbl =~ /map/);
ok($str_tbl =~ /rpm/);
ok($str_tbl =~ /100/);

ok($lut->get_x_coords());
ok($lut->get_y_coords());

# }}}

# {{{ detailed checks of an non-square table

{
my $str_tbl = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [400]   1       2       3
 map   [300]   4       5       6
       [200]   7       8       9
       [100]   10      11      12

";

my $lut = Text::LookUpTable->load($str_tbl);

my @xs = $lut->get_x_coords();
ok(3 == @xs);

my @ys = $lut->get_y_coords();
ok(4 == @ys);

ok(10 == $lut->get(0, 0));
ok(4 == $lut->get(0, 2));
ok(5 == $lut->get(1, 2));
ok(3 == $lut->get(2, 3));

}
# }}}

# {{{ save a reload from a file DISABLED
# Try saving a table to a file and make sure it is equivalent
# after it is re-loaded.

# This test caused a failure on CPAN Testers
# [http://www.cpantesters.org/cpan/report/07648452-b19f-3f77-b713-d32bba55d77f]
# with a permission denied error due to the file created.
# TODO - How can this test be performed?

#my $tmp_file = '/tmp/lut-test-DELETE_ME.tbl';
#
#my $res = $lut->save_file($tmp_file);
#ok($res);
#
#my $tbl3 = Text::LookUpTable->load_file($tmp_file);
#ok($tbl3);
#
#ok("$tbl2" eq "$tbl3");
# }}}

# Try to load some faulty tables and make sure the error is caught.
# Errors will be displayed but the tests here should still pass.

## {{{ TODO all values must be present, this one has one missing
#{
#my $str_bad = 
#"
#                     rpm
#
#               [1.25]  [3.35]  [4.97]  [5.66]
#       [100]   1       2       3       4     
# map   [200]   2       2       4       5     
#       [300]   10      -10     13      15    
#       [400]   10      -10     13
#
#";
#
#my $blut = Text::LookUpTable->load($str_bad);
#ok(! $blut);
#}
## }}}

## {{{ TODO too many coordinates
#{
#my $str_bad = 
#"
#                     rpm
#
#       [222]   [1.25]  [3.35]  [4.97]  [5.66]
#       [100]   1       2       3       4     
# map   [200]   2       2       4       5     
#       [300]   10      -10     13      15    
#       [400]   10      -10     13      2
#
#";
#
#my $blut = Text::LookUpTable->load($str_bad);
#ok(! $blut);
#}
## }}}

## {{{ TODO too many y titles
#{
#my $str_bad = 
#"
#                     rpm
#
#               [1.25]  [3.35]  [4.97]  [5.66]
#       [100]   1       2       3       4     
# map   [200]   2       2       4       5     
# jfji  [300]   10      -10     13      15    
#       [400]   10      -10     13      2
#
#";
#
#my $blut = Text::LookUpTable->load($str_bad);
#ok(! $blut);
#}
## }}}

## {{{ TODO too many x titles
#{
#my $str_bad = 
#"
#                     rpm
#                     rpm
#
#               [1.25]  [3.35]  [4.97]  [5.66]
#       [100]   1       2       3       4     
# map   [200]   2       2       4       5     
#       [300]   10      -10     13      15    
#       [400]   10      -10     13      2
#
#";
#
#my $blut = Text::LookUpTable->load($str_bad);
#ok(! $blut);
#}
## }}}

# {{{ set values
{
my $str_tblA = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [400]   1       2       3
 map   [300]   4       5       6
       [200]   7       8       9
       [100]   10      11      12

";

my $str_tblB = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [400]   1       2       3
 map   [300]   4       5       6
       [200]   7       8       9
       [100]   10      11      666

";

my $tblA = Text::LookUpTable->load($str_tblA);


my $tblB = Text::LookUpTable->load($str_tblB);
# Table B must be loaded before testing equality because
# there might be slight spacing differences which would
# cause the equality test to fail.

ok("$tblA" ne "$tblB");

$tblA->set(2, 0, 666);

ok("$tblA" eq "$tblB");
}
# }}}

# {{{ diff

{
my $str_tblA = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [400]   1       2       3
 map   [300]   4       5       6
       [200]   7       8       9
       [100]   10      11      12

";

my $str_tblB = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [400]   1       2       3
 map   [300]   4       5       6
       [200]   7       8       9
       [100]   10      11      666

";

my $tblA = Text::LookUpTable->load($str_tblA);

my $tblB = Text::LookUpTable->load($str_tblB);
# Table B must be loaded before testing equality because
# ther might be slight spacing differences which would
# cause the equality test to fail.

# they should be different
ok($tblA->diff($tblB, 1));
ok($tblA->diff($tblB));

my @dp = $tblA->diff($tblB);
ok($dp[0][0] == 2); # x
ok($dp[0][1] == 0); # y

#$tblA->set(2, 3, 666);
$tblA->set(@{$dp[0]}, 666);

ok(! $tblA->diff($tblB, 1));
ok(! $tblA->diff($tblB));

ok("$tblA" eq "$tblB");

}
# }}}

# {{{ build

{
my $str_tblA = 
"
               x

            [0]  [0]
       [0]   0       0
 y     [0]   0       0
       [0]   0       0
       [0]   0       0

";

my $tblA = Text::LookUpTable->load($str_tblA);
ok($tblA);

my $tblB = Text::LookUpTable->build(2, 4, "x", "y");
ok($tblB);

ok("$tblA" eq "$tblB");
}
# }}}

# {{{ set_*_coords

{
my $str_tblA = 
"
               x

            [5]  [6]
       [1]   0       0
 y     [2]   0       0
       [3]   0       0
       [4]   0       0

";

my $tblA = Text::LookUpTable->load($str_tblA);
ok($tblA);

my $tblB = Text::LookUpTable->build(2, 4, "x", "y");
ok($tblB);

$tblB->set_y_coords(1, 2, 3, 4);

$tblB->set_x_coords(5, 6);

# debug
#print STDERR $tblA;
#print STDERR $tblB;

ok("$tblA" eq "$tblB");

}
# }}}

# {{{ diff_*_coords

{

# These tables have the same values but different coordinates.

my $str_tblA = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [400]   1       2       3
 map   [300]   4       5       6
       [200]   7       8       9
       [100]   10      11      12

";

my $str_tblB = 
"
                     rpm

               [2.25]  [3.35]  [4.97]
       [400]   1       2       3
 map   [300]   4       5       6
       [222]   7       8       9
       [100]   10      11      666

";

my $tblA = Text::LookUpTable->load($str_tblA);
ok($tblA);

my $tblB = Text::LookUpTable->load($str_tblB);
ok($tblB);

{
my @diff = $tblA->diff_x_coords($tblB);
ok(1 == @diff);
ok($diff[0] == 0);
}

{
my @diff = $tblA->diff_y_coords($tblB);
ok(1 == @diff);
ok($diff[0] == 1);
}

}
# }}}

# {{{ lookup_points
{
my $epsilon = 0.01;

my $str_start = 
"
                        rpm
 
              [1000]   [1500]  [2000]  [2500] [3000]
       [100]  14.0     15.5    16.4    17.9    21.9
  map  [90]   13.0     14.5    15.3    16.8    21.9
       [80]   12.0     13.5    14.2    15.7    20.5
       [70]   12.0     13.5    14.2    15.7    20.1
       [60]   12.0     13.5    14.2    15.7    18.2

";

my $lut = Text::LookUpTable->load($str_start);

# get(x, y)
ok(($lut->get(0, 0) - 12.0) < $epsilon);
ok(($lut->get(0, 3) - 13.0) < $epsilon);
ok(($lut->get(0, 4) - 14.0) < $epsilon);
ok(($lut->get(4, 4) - 21.9) < $epsilon);

# The coordinates should be in ascending(increasing) order
my @y_coords = $lut->get_y_coords();
ok($y_coords[0] == 60);
ok($y_coords[4] == 100);

my @x_coords = $lut->get_x_coords();
ok($x_coords[0] == 1000);
ok($x_coords[4] == 3000);

my @points;

# lookup points in the middle
@points = $lut->lookup_points(2010, 85, 1);
ok(9 == @points);
ok(grep { ($_->[0] == 3 and $_->[1] == 3); } @points);
ok(grep { ($_->[0] == 1 and $_->[1] == 1); } @points);
ok(grep { ($_->[0] == 1 and $_->[1] == 2); } @points);


#looku points at a corner
@points = $lut->lookup_points(3010, 150.0, 1);
ok(4 == @points);
ok(grep { ($_->[0] == 3 and $_->[1] == 3); } @points);
ok(grep { ($_->[0] == 4 and $_->[1] == 4); } @points);
ok(grep { ($_->[0] == 3 and $_->[1] == 4); } @points);
ok(grep { ($_->[0] == 4 and $_->[1] == 4); } @points);

# should still be at a corner when close enough but below
@points = $lut->lookup_points(2990, 96, 1);
ok(4 == @points);
ok(grep { ($_->[0] == 3 and $_->[1] == 3); } @points);
ok(grep { ($_->[0] == 4 and $_->[1] == 4); } @points);
ok(grep { ($_->[0] == 3 and $_->[1] == 4); } @points);
ok(grep { ($_->[0] == 4 and $_->[1] == 4); } @points);

# at a different corner
@points = $lut->lookup_points(900, 96, 1);
ok(4 == @points);
ok(grep { ($_->[0] == 0 and $_->[1] == 3); } @points);
ok(grep { ($_->[0] == 0 and $_->[1] == 4); } @points);
ok(grep { ($_->[0] == 1 and $_->[1] == 3); } @points);
ok(grep { ($_->[0] == 1 and $_->[1] == 4); } @points);

# bottom side
@points = $lut->lookup_points(1600, 62, 1);
ok(6 == @points);
ok(grep { ($_->[0] == 0 and $_->[1] == 0); } @points);
ok(grep { ($_->[0] == 0 and $_->[1] == 1); } @points);
ok(grep { ($_->[0] == 1 and $_->[1] == 0); } @points);
ok(grep { ($_->[0] == 1 and $_->[1] == 1); } @points);
ok(grep { ($_->[0] == 2 and $_->[1] == 0); } @points);
ok(grep { ($_->[0] == 2 and $_->[1] == 1); } @points);

# a wider range
@points = $lut->lookup_points(2900, 62, 2);
ok(9 == @points);
ok(grep { ($_->[0] == 2 and $_->[1] == 0); } @points);
ok(grep { ($_->[0] == 2 and $_->[1] == 1); } @points);
ok(grep { ($_->[0] == 2 and $_->[1] == 2); } @points);
ok(grep { ($_->[0] == 3 and $_->[1] == 1); } @points);
ok(grep { ($_->[0] == 3 and $_->[1] == 0); } @points);
ok(grep { ($_->[0] == 3 and $_->[1] == 2); } @points);
ok(grep { ($_->[0] == 4 and $_->[1] == 1); } @points);
ok(grep { ($_->[0] == 4 and $_->[1] == 0); } @points);
ok(grep { ($_->[0] == 4 and $_->[1] == 2); } @points);

# a zero range
@points = $lut->lookup_points(2900, 62, 0);
ok(1 == @points);
ok(grep { ($_->[0] == 4 and $_->[1] == 0); } @points);


}
# }}}

# {{{ copy

{
my $str_tbl = 
"
               x

            [0]  [1]
       [4]   3       7
 y     [3]   2       6
       [2]   1       5
       [1]   0       4

";

my $tbl = Text::LookUpTable->load($str_tbl);

my $tbl_orig = $tbl->copy();

ok("$tbl_orig" eq "$tbl");

$tbl->set(1, 0, 10);

ok("$tbl" ne "$tbl_orig");

ok(10 == $tbl->get(1, 0));
ok(4 == $tbl_orig->get(1, 0));
}
# }}}
