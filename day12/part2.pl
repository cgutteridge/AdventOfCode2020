#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my @cmds = ();
foreach my $row ( @rows ) {
	my $ok = $row =~ m/^([NSEWLRF])(\d+)$/;
	die $row if( !$ok );
	push @cmds, [$1,$2];
}
my $x=0;
my $y=0;
my $wp = [10,-1];
my $r=[
	[ 0, -1 ],
	[ 1,  0 ],
];
my $l=[
	[ 0, 1 ],
	[ -1,0 ],
];
my @dirs = qw/ E S W N /;
my $mod = {
	E=>[1,0],
	S=>[0,1],
	W=>[-1,0],
	N=>[0,-1],
};
foreach my $cmd ( @cmds ) {
	print sprintf( "%i,%i wp %i/%i",$x,$y,$wp->[0], $wp->[1]);
	print " .. "; 
	print sprintf( "%s %i", $cmd->[0], $cmd->[1] ); 
	print "\n";
	if( $cmd->[0] eq "L" ) {
		for(my $i=0;$i<$cmd->[1];$i+=90) {
			# FML vectors
			$wp = [ 
				$wp->[0]*$l->[0]->[0] + $wp->[1]*$l->[0]->[1] ,
				$wp->[0]*$l->[1]->[0] + $wp->[1]*$l->[1]->[1] 
			];
		}
		next;
	}
	if( $cmd->[0] eq "R" ) {
		for(my $i=0;$i<$cmd->[1];$i+=90) {
			# FML vectors
			$wp = [ 
				$wp->[0]*$r->[0]->[0] + $wp->[1]*$r->[0]->[1] ,
				$wp->[0]*$r->[1]->[0] + $wp->[1]*$r->[1]->[1] 
			];
		}
		next;
	}
	if( $cmd->[0] eq "F" ) { 
		$x += $cmd->[1]*$wp->[0];
		$y += $cmd->[1]*$wp->[1];
		next;
	}
	my $dir = $cmd->[0];
	my $v = $mod->{$dir};
	$wp->[0] += $cmd->[1]*$v->[0];
	$wp->[1] += $cmd->[1]*$v->[1];
}

print sprintf( "PART2 = %d+%d = %d\n", abs($x), abs($y), abs($x)+abs($y) );
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
