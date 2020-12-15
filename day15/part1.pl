#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @n =(14,8,16,0,1,17);
my $num;
my $oldnum;
my $last = {};
for(my $i=1;$i<=@n;$i++ ) {
	$num = $n[$i-1];

	$last->{$oldnum}=$i-1 if defined $oldnum;
	$oldnum = $num;
}

for(my $i=scalar @n+1;$i<=2020;$i++) {
	if( !defined $last->{$num} ) {
		$num = 0;
	} else {
		$num = $i-1-$last->{$num};
	}
	
	$last->{$oldnum}=$i-1 if defined $oldnum;
	$oldnum = $num;
}


print sprintf( "PART1 = %d\n", $num );
exit;

