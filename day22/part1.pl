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

while( @{$decks->[1]} && @{$decks->[2]} ) {
	my $p1 = shift @{$decks->[1]};
	my $p2 = shift @{$decks->[2]};
	# print "1: $p1\n2: $p2\n";
	if( $p1>$p2 ) {
		push @{$decks->[1]}, $p1, $p2;
	} else {
		push @{$decks->[2]}, $p2, $p1;
	}
	#print Dumper( $decks );
	#print "\n";
}
my $winner = @{$decks->[1]}?1:2;
my @list = @{$decks->[$winner]};
my $v = 0;
my $m = 1;
while( @list ) {
	$v += $m * pop @list;
	$m++;
}
# print Dumper( $decks );

print sprintf( "PART1 = %d\n", $v );
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
