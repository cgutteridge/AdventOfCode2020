#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my @j = sort {$a <=> $b} @rows;
unshift @j, 0;
my $max = $j[-1]+3;
push @j, $max;
#print Dumper( \@j);
my $routes = {};
foreach my $joltage ( @j ) { $routes->{$joltage} = 0; }
$routes->{0} = 1;

for( my $i=0;$i<@j-1;$i++ ) {
	my $joltage = $j[$i];
	my $r = $routes->{$joltage};
	# $r ways to get to $joltage	
	for( my $inc=1;$inc<4;$inc++ ) {
		if( defined $routes->{$joltage+$inc} ) {
			$routes->{$joltage+$inc}+=$r;
		}
	}
}

print sprintf( "PART2 = %d\n", $routes->{$max} );
exit;


sub readfile {
	my( $filename ) = @_;
	my @rows = ();
	open( my $fh, "<", $filename ) || die "can't read $filename";
	while( my $line = readline( $fh ) ) {
		chomp $line;
		push @rows, $line;
	}
	return @rows
}
