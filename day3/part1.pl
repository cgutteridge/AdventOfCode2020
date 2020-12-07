#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
#print Dumper( \@rows );
my $XD = 3;
my $YD = 1;
my $x = 0;
my $y = 0;

my $trees = 0;
while(1) {
	$x += $XD;
	$y += $YD;
 	last if( $y >=  @rows );
#	print "($x,$y)\n";
	my $row = $rows[$y];
	my $spot = substr( $row, $x % length($row), 1 );
	$trees++ if( $spot eq "#" );
#	print "$spot\n";
}
print "PART1=$trees\n";

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
