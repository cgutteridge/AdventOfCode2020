#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );

my @groups = ();
my $group = {};
foreach my $row ( @rows ) {
	if( $row eq "" ) {
		push @groups, $group;
		$group = {};	
		next;
	}
	foreach my $c ( split //, $row ) {
		$group->{$c}=1;
	}
}
push @groups, $group;
#print Dumper( \@groups );

my $sum = 0;
foreach my $group ( @groups ) {
	$sum += scalar keys %$group;
}
print "PART1=$sum\n";

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
