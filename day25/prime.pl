#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $n=20201227;
my $max = sqrt( $n);
for(my $i=2;$i<=$max;$i++ ) {
	if( $n % $i == 0 ) { print "$i\n"; }
}
