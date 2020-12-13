#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my $ready_to_leave = $rows[0];
my @buses = split( ",", $rows[1]);
my $min_time;
my $min_bus;
my $min_loops;

BUS: foreach my $bus ( @buses ) {
	next if $bus eq "x";
	my $time = 0;
	my $loops = 0;
	while(1) {
		if( $time >= $ready_to_leave ) {
			if( !defined $min_time || $time<$min_time) {
				$min_time = $time;
				$min_bus = $bus;
				$min_loops = $loops;
			}
			next BUS;
		}
		$time+=$bus;
		$loops++;
	}
}
my $wait = $min_time-$ready_to_leave;
print sprintf( "PART1 = %d*%d = %d\n", $min_bus, $wait, $min_bus*$wait );
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
