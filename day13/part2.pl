#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my @list = split( ",", $rows[1]);
my $offs = {};
my @buses = ();
for( my $i=0; $i<@list; ++$i ) {
	if( $list[$i] ne "x" ) {
		push @buses, $list[$i]; # preserve order
		$offs->{$list[$i]}=$i;
	}
}
#print Dumper ( $offs );

# assumption: all bus loops are prime numbers
# find the number of iteraions between two buses to get the right offset, then the number of interations of that to get the next

# start is when this configuration of bus offsets first occurs
my $start = 0;
# loop size is how many minutes until this configuration of bus offset recurs.
my $loop_size = 1;

BUS: foreach my $bus ( @buses ) {
	my $offset = $offs->{$bus};
	if( !defined $loop_size ) {
		$start = $offset;
		$loop_size*=$bus;
		next BUS;
	}

	my $loops = solveFunc( $loop_size, $start+$offset, $bus );
	$start = $start + $loops * $loop_size;
	$loop_size = $loop_size * $bus;
}
print sprintf( "PART2 = %d\n", $start );
exit;

# find x where (Ax+B)%C=0
sub solveFunc {
	my( $A, $B, $C ) = @_;
print "0=$A x X + $B % $C\n";

	for(my $x=0;$x<$C;$x++) {
		return $x if ($A*$x+$B)%$C==0;
	}
	die "no solution";
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
