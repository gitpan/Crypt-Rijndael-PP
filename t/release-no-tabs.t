
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.06

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Crypt/Rijndael/PP.pm',
    'lib/Crypt/Rijndael/PP.pod',
    'lib/Crypt/Rijndael/PP/Debug.pm',
    'lib/Crypt/Rijndael/PP/GF.pm'
);

notabs_ok($_) foreach @files;
done_testing;
