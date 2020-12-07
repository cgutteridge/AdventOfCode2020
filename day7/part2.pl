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

my $n = count( $rules, "shiny gold" );	
print sprintf( "PART2 = %d\n", $n );

exit;

sub count {
	my( $tree, $id ) = @_;

	my $n = 0;
	my $node = $tree->{$id};
	foreach my $child_i ( keys %$node ) {
		my $child_n = $node->{$child_i}; # number of this bag
		$n += $child_n * ( 1 + count( $tree, $child_i ));
	}
	return $n;
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
