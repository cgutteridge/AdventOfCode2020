#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# |   |   |   |   |   |
#  \ / \ / \ / \ / \ / \
#   |   |   |   |   |   |
#   |-2 |-2 |-2 |-2 |-2 |
#  / \ / \ / \ / \ / \ /
# |-2 |-1 | 0 | 1 | 2 |
# |-1 |-1 |-1 |-1 |-1 |
#  \ / \ / \ / \ / \ / \
#   |-2 |-1 | 0,| 1 | 2 |
#   | 0 | 0 | 0 | 0 | 0 |
#  / \ / \ / \ / \ / \ /
# |-3 |-2 |-1 | 0 | 1 |
# | 1 | 1 | 1 | 1 | 1 |
#  \ / \ / \ / \ / \ / \
#   |   |   |   |   |   |
#   |   |   |   |   |   |
#  / \ / \ / \ / \ / \ /

my $V = {
	e=>[1,0],
	w=>[-1,0],
	ne=>[1,-1],
	nw=>[0,-1],
	se=>[0,1],
	sw=>[-1,1],
};
my @rows = readfile( "data" );
my @flips=();
foreach my $row ( @rows ) {
	print $row."\n";
	my $list = [];
	while( $row ne "" ) {
		$row =~ s/^(ne|nw|se|sw|e|w)//;
		push @$list, $1;
	}
	push @flips,$list;
	print Dumper( $list );
}

# white = 0/undef
my $floor = {};	
my $black = 0;
foreach my $list (@flips) {
	my $vx=0;
	my $vy=0;
	foreach my $flip ( @$list ) {
		$vx += $V->{$flip}->[0];
		$vy += $V->{$flip}->[1];
	}
	if( !defined $floor->{$vy}->{$vx} ) {
		print "$vx,$vy first flip to black\n";
		$floor->{$vy}->{$vx} = 1;
		$black++;
	} elsif( $floor->{$vy}->{$vx} ) {
		print "$vx,$vy flip to white\n";
		$floor->{$vy}->{$vx} = 0;
		$black--;
	} else {
		print "$vx,$vy flip to black\n";
		$floor->{$vy}->{$vx} = 1;
		$black++;
	}
}

print sprintf( "PART1 = %d\n", $black);
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
