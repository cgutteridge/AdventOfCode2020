#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
#print Dumper( \@rows );
my $rules = {};
my $can_be_in = {};
#dim brown bags contain 1 bright yellow bag, 3 faded cyan bags, 4 dotted chartreuse bags.
foreach my $row ( @rows ) {
	#print "1.$row\n";
	$row =~ s/ bags?([ ,\.])/$1/g;
	$row =~ s/\.$//;
	#print "2.$row\n";
	my( $outer, $inner_list ) = split( / contain /, $row );
	my $inner = {};
	if( $inner_list ne "no other" ) {
		foreach my $inner_item ( split( /, /, $inner_list )) {
			my $ok = $inner_item =~ m/^(\d+) (.*)$/;			
			die $inner_item unless $ok;
			$inner->{$2} = $1;
		}
	}
	$rules->{$outer} = $inner;
	foreach my $inner_i ( keys %$inner ) {
		$can_be_in->{$inner_i}->{$outer} = 1;
	}
}

my $list = can_be_inside( $can_be_in, "shiny gold" );	
print sprintf( "PART1 = %d\n", scalar keys %$list );

exit;

sub can_be_inside {
	my( $tree, $id ) = @_;

	my $results = {};
	my $node = $tree->{$id};
	foreach my $parent_i ( keys %$node ) {
		$results->{$parent_i} = 1;
		my $r2 = can_be_inside( $tree, $parent_i );
		foreach my $r2_i ( keys %$r2 ) {
			$results->{$r2_i}=1;
		}
	}
	return $results;
}
	

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
