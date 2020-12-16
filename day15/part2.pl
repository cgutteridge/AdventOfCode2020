#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @n =(14,8,16,0,1,17);
#@n= ( 0,3,6);
my $num;
my $oldnum;
my $last = {};
for(my $i=1;$i<=@n;$i++ ) {
	$num = $n[$i-1];

	$last->{$oldnum}=$i-1 if defined $oldnum;
	$oldnum = $num;
}

my $start = time();
my $MAX=30000000;
for(my $i=scalar @n+1;$i<=$MAX;$i++) {
	if( $i % 3000000 == 0 ) {
		my $t = time()-$start; 
		print sprintf( "%d %ds %0.4f\n", $i, $t, $i/$MAX );
	}
	if( !defined $last->{$num} ) {
		$num = 0;
	} else {
		$num = $i-1-$last->{$num};
	}
	
	$last->{$oldnum}=$i-1 if defined $oldnum;
	$oldnum = $num;
}

print "".(scalar keys %$last)."\n";
print sprintf( "PART2 = %d\n", $num );
exit;

