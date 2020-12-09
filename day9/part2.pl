#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $TARGET = 50047984;
my @rows = readfile( "data" );
#$TARGET=127;
#@rows = readfile( "example" );
MAIN: for( my $i=0; $i<@rows; ++$i ) {
	my $sum = 0;
	my $j=$i;
	my $small=$rows[$j];
	my $large=$rows[$j];
	while( $sum <= $TARGET && $j<@rows ) {
		$small=$rows[$j] if $rows[$j]<$small;
		$large=$rows[$j] if $rows[$j]>$large;
		$sum += $rows[$j];
		if( $sum == $TARGET ) {
			print sprintf( "PART2 = %d\n", $small+$large );
			exit;
		}
		++$j;
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
