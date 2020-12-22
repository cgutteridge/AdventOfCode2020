#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
my $file= "data";
my @rows = readfile( $file );

my $decks = [];
my $p;
foreach my $row ( @rows ) {
	next if $row eq "";
	if( $row =~ m/^Player (\d):/ ) {
		$p=$1;
		next;
	}
	if( $row =~ m/^\d+$/ ) {
		push @{$decks->[$p]}, $row+0;
	}
}
#print Dumper( $decks );

my( $winner, $list ) = rcombat( $decks );

my $v = 0;
my $m = 1;
 print Dumper( $list );
while( @$list ) {
	$v += $m * pop @$list;
	$m++;
}
print sprintf( "PART2 = %d\n", $v );
exit;

sub rcombat {
	my( $decks ) = @_;

	my $states = {};
	while( @{$decks->[1]} && @{$decks->[2]} ) {

		my $state = join( ",",@{$decks->[1]}).";".join( ",",@{$decks->[2]});
		if( $states->{$state} ) {
			print "STATE SEEN BEFORE\n";	
			return( 1, $decks->[1] );
		}
		$states->{$state}=1;
		
		my $p1 = shift @{$decks->[1]};
		my $p2 = shift @{$decks->[2]};

		my $winner;
		my $junk;
		if( $p1	<= @{$decks->[1]} && $p2 <= @{$decks->[2]} ) {
			my $newdecks;
			for my $i (0..$p1-1) { push @{$newdecks->[1]}, $decks->[1]->[$i]; }
			for my $i (0..$p2-1) { push @{$newdecks->[2]}, $decks->[2]->[$i]; }
#			print Dumper( $newdecks );
			# recursse
			($winner,$junk) = rcombat( $newdecks );
print "[$winner]\n";
		} else {
			$winner = $p1>$p2 ? 1 : 2;
		}
		
		# print "1: $p1\n2: $p2\n";
		if( $winner == 1 ) {
			push @{$decks->[1]}, $p1, $p2;
		} else {
			push @{$decks->[2]}, $p2, $p1;
		}
		#print Dumper( $decks );
		#print "\n";
	}
	my $winner =  @{$decks->[1]} ? 1 : 2;
	return( $winner, $decks->[$winner] );
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
