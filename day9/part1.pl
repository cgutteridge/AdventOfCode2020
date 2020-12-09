#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $L = 25;
my @rows = readfile( "data" );
MAIN: for( my $i=$L; $i<@rows; ++$i ) {
	for( my $j=$i-$L; $j<$i-1; $j++ ) {
		K: for( my $k=$j+1; $k<$i; $k++ ) {
			next K if $j==$k;
			next MAIN if( $rows[$j]+$rows[$k]==$rows[$i] );
		}
	}

	print sprintf( "PART1 = %d\n", $rows[$i] );	
	exit;
}

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
