#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );

my @groups = ();
my $group = undef;
foreach my $row ( @rows ) {
	if( $row eq "" ) {
		push @groups, $group;
		$group = undef;
		next;
	}
	my $person = {};	
	foreach my $c ( split //, $row ) {
		$person->{$c}=1;
	}
	if( !defined $group ) { 
		$group = $person;
	} else {
		foreach my $k ( keys %$group ) {
			delete $group->{$k} if( !defined $person->{$k} );
		}
	}
}
push @groups, $group;
#print Dumper( \@groups );

my $sum = 0;
foreach my $group ( @groups ) {
	$sum += scalar keys %$group;
}
print "PART2=$sum\n";

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
