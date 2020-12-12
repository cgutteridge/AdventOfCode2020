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
my $h=0;
my @dirs = qw/ E S W N /;
my $mod = {
	E=>[1,0],
	S=>[0,1],
	W=>[-1,0],
	N=>[0,-1],
};
foreach my $cmd ( @cmds ) {
	#print sprintf( "%i,%i %s",$x,$y,$dirs[$h]); print " .. "; print sprintf( "%s %i", $cmd->[0], $cmd->[1] ); print "\n";
	if( $cmd->[0] eq "L" ) {
		$h = ($h - $cmd->[1]/90)%4;
		next;
	}
	if( $cmd->[0] eq "R" ) {
		$h = ($h + $cmd->[1]/90)%4;
		next;
	}
	my $dir = $cmd->[0];
	if( $dir eq "F" ) { $dir = $dirs[$h]; }
	my $v = $mod->{$dir};
	$x += $cmd->[1]*$v->[0];
	$y += $cmd->[1]*$v->[1];
}

print sprintf( "PART1 = %d+%d = %d\n", abs($x), abs($y), abs($x)+abs($y) );
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
