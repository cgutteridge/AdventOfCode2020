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
	my $list = [];
	while( $row ne "" ) {
		$row =~ s/^(ne|nw|se|sw|e|w)//;
		push @$list, $1;
	}
	push @flips,$list;
}

my $bounds = {
	min => {x=>0,y=>0},
	max => {x=>0,y=>0},
};
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
	if( $floor->{$vy}->{$vx} ) {
		$floor->{$vy}->{$vx} = 0;
		$black--;
	} else {
		$floor->{$vy}->{$vx} = 1;
		$black++;
	}
	$bounds->{min}->{x}=$vx if( $vx<$bounds->{min}->{x} );
	$bounds->{min}->{y}=$vy if( $vy<$bounds->{min}->{y} );
	$bounds->{max}->{x}=$vx if( $vx>$bounds->{max}->{x} );
	$bounds->{max}->{y}=$vy if( $vy>$bounds->{max}->{y} );
}

printfloor( $floor, $bounds ); 

for my $day ( 1..100 ) {
	my $oldfloor = $floor;
	my $oldbounds = $bounds;
	
	$bounds = {
		min => {x=>0,y=>0},
		max => {x=>0,y=>0},
	};
	# white = 0/undef
	$floor = {};	
	$black = 0;
	for( my $y=$oldbounds->{min}->{y}-1;$y<=$oldbounds->{max}->{y}+1;$y++ ) {
	for( my $x=$oldbounds->{min}->{x}-1;$x<=$oldbounds->{max}->{x}+1;$x++ ) {
		my $tile = $oldfloor->{$y}->{$x};
		my $adj = 0;
		foreach my $dir ( keys %$V ) {
			$adj++ if $oldfloor->{$y+$V->{$dir}->[1]}->{$x+$V->{$dir}->[0]};
		}
		if( ( $tile && ($adj==1 || $adj==2) )   || (!$tile && $adj==2 ) ) {
			$floor->{$y}->{$x} = 1;
			$black++;
		}
		$bounds->{min}->{x}=$x if( $x<$bounds->{min}->{x} );
		$bounds->{min}->{y}=$y if( $y<$bounds->{min}->{y} );
		$bounds->{max}->{x}=$x if( $x>$bounds->{max}->{x} );
		$bounds->{max}->{y}=$y if( $y>$bounds->{max}->{y} );
	}}
	#printfloor( $floor,$bounds);
	print "$day .. $black\n";
}

print sprintf( "PART2 = %d\n", $black);
	
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
sub printfloor {
	my( $floor, $bounds ) = @_;

	my $o=0;
	for( my $y=$bounds->{min}->{y}-1;$y<=$bounds->{max}->{y}+1;$y++ ) {
	#  \ / \ / \ / \ / \ / \
	#   |   |   |   |   |   |
	#  / \ / \ / \ / \ / \ /
		print "  "x$o;
		for( my $x=$bounds->{min}->{x}-1;$x<=$bounds->{max}->{x}+1;$x++ ) {
			print " /".($x==0&&$y==0?"*":" ")."\\";
		}
		print "\n";
		print "  "x$o;
		for( my $x=$bounds->{min}->{x}-1;$x<=$bounds->{max}->{x}+1;$x++ ) {
			if( $floor->{$y}->{$x} ) {	
				print "| # ";
			} else {
				print "|   ";
			}
		}
		print "\n";
		$o++; 
	}
}
