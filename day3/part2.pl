#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
#print Dumper( \@rows );

my @routes = (
    {right=> 1, down=> 1},
    {right =>3, down=> 1},
    {right =>5, down=> 1},
    {right =>7, down=> 1},
    {right =>1, down=> 2},
);

my $ans = 1;
foreach my $route ( @routes ) {
	
	my $x = 0;
	my $y = 0;
	
	my $trees = 0;
	while(1) {
		$x += $route->{right};
		$y += $route->{down};
 		last if( $y >=  @rows );
	#	print "($x,$y)\n";
		my $row = $rows[$y];
		my $spot = substr( $row, $x % length($row), 1 );
		$trees++ if( $spot eq "#" );
	#	print "$spot\n";
	}
	print "ROUTE=$trees\n";
	$ans *= $trees;
}
print "PART2=$ans\n";

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
