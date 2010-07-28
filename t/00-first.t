#!perl -w
use strict;
use warnings;

use Test::More;
plan tests => 37;

use_ok('Text::LookUpTable');

# {{{ some basic checks
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

ok($lut->get_x_vals(3));

ok($lut->get_x_coords());
ok($lut->get_y_coords());

#print $str_tbl;
#ok($lut->load_file('/tmp/lut-test-DELETE_ME.tbl'));


# Load the string version of a table and check that
# it is equivalent.

$str_tbl = "$lut";

my $tbl2 = Text::LookUpTable->load($str_tbl);
ok($tbl2);

my $str_tbl2 = $lut;

ok("$tbl2" eq "$lut");
# }}}

# {{{ detailed checks of an non-square table

{
my $str_tbl = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [100]   1       2       3
 map   [200]   4       5       6
       [300]   7       8       9
       [400]   10      11      12

";

my $lut = Text::LookUpTable->load($str_tbl);

my @xs;
my @ys;

@xs = $lut->get_x_coords();
ok(3 == @xs);

@ys = $lut->get_y_coords();
ok(4 == @ys);

@xs = $lut->get_x_vals(1);
ok(3 == @xs);

ok($xs[0] == 4);
ok($xs[1] == 5);
ok($xs[2] == 6);

@ys = $lut->get_y_vals(1);
ok(4 == @ys);
# offset starts at 0 at the top
ok($ys[0] == 11);
ok($ys[1] == 8);
ok($ys[2] == 5);
ok($ys[3] == 2);

}
# }}}

# {{{ save a reload from a file
# Try saving a table to a file and make sure it is equivalent
# after it is re-loaded.

my $tmp_file = '/tmp/lut-test-DELETE_ME.tbl';

my $res = $lut->save_file($tmp_file);
ok($res);

my $tbl3 = Text::LookUpTable->load_file($tmp_file);
ok($tbl3);

ok("$tbl2" eq "$tbl3");
# }}}

# Try to load some faulty tables and make sure the error is caught.
# Errors will be displayed but the tests here should still pass.

# {{{ all values must be present, this one has one missing
{
my $str_bad = 
"
                     rpm

               [1.25]  [3.35]  [4.97]  [5.66]
       [100]   1       2       3       4     
 map   [200]   2       2       4       5     
       [300]   10      -10     13      15    
       [400]   10      -10     13

";

my $blut = Text::LookUpTable->load($str_bad);
ok(! $blut);
}
# }}}

# {{{ too many coordinates
{
my $str_bad = 
"
                     rpm

       [222]   [1.25]  [3.35]  [4.97]  [5.66]
       [100]   1       2       3       4     
 map   [200]   2       2       4       5     
       [300]   10      -10     13      15    
       [400]   10      -10     13      2

";

my $blut = Text::LookUpTable->load($str_bad);
ok(! $blut);
}
# }}}

# {{{ too many y titles
{
my $str_bad = 
"
                     rpm

               [1.25]  [3.35]  [4.97]  [5.66]
       [100]   1       2       3       4     
 map   [200]   2       2       4       5     
 jfji  [300]   10      -10     13      15    
       [400]   10      -10     13      2

";

my $blut = Text::LookUpTable->load($str_bad);
ok(! $blut);
}
# }}}

# {{{ too many x titles
{
my $str_bad = 
"
                     rpm
                     rpm

               [1.25]  [3.35]  [4.97]  [5.66]
       [100]   1       2       3       4     
 map   [200]   2       2       4       5     
       [300]   10      -10     13      15    
       [400]   10      -10     13      2

";

my $blut = Text::LookUpTable->load($str_bad);
ok(! $blut);
}
# }}}

# {{{ set values

{
my $str_tblA = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [100]   1       2       3
 map   [200]   4       5       6
       [300]   7       8       9
       [400]   10      11      12

";

my $str_tblB = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [100]   1       2       3
 map   [200]   4       5       6
       [300]   7       8       9
       [400]   10      11      666

";

my $tblA = Text::LookUpTable->load($str_tblA);


my $tblB = Text::LookUpTable->load($str_tblB);
# Table B must be loaded before testing equality because
# ther might be slight spacing differences which would
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
       [100]   1       2       3
 map   [200]   4       5       6
       [300]   7       8       9
       [400]   10      11      12

";

my $str_tblB = 
"
                     rpm

               [1.25]  [3.35]  [4.97]
       [100]   1       2       3
 map   [200]   4       5       6
       [300]   7       8       9
       [400]   10      11      666

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

