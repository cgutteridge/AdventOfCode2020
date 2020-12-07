#!/usr/bin/perl

use strict;
use warnings;

my @rows = readfile( "data" );
for( my $i=0;$i<scalar @rows-1; $i++ ) {
	for( my $j=$i+1;$j<scalar @rows; $j++ ) {
	 	#print sprintf( "%i + %i = %i\n", $rows[$i], $rows[$j], $rows[$i]+$rows[$j] );
		if( $rows[$i] + $rows[$j] == 2020 ) {
	 		print sprintf( "%i + %i | %i\n", $rows[$i], $rows[$j], $rows[$i]*$rows[$j] );
			exit;	
		}
	}
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
