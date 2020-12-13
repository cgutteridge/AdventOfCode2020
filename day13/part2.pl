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
my $start = 0;
my $loop_size = 1;;
BUS: foreach my $bus ( @buses ) {
	my $offset = $offs->{$bus};
	if( !defined $loop_size ) {
		$start = $offset;
		$loop_size*=$bus;
		next BUS;
	}

	#print "$bus / $offset\n";
	# how many times do we have to do this loop so that bus $bus is $offset minutes ahead?
	my $loops = 0;
	while(1) {
		my $time = $start + $loops * $loop_size;
		# does the new bus leave $offset minutes after this?
		my $l = ($time+$offset) / $bus;
	#print "bus=$bus time=$time l=$l \n";
		if( $l == int $l ) {
			# yes (it's an interger number of times)
			# to get to the same state for the other buses we have to do a loop the size of the sum of their primes. 
			# and as they are all prime, it's just their sum
			$loop_size = $loop_size*$bus;
			$start = $time;
			next BUS;
		}
		$loops++;
	}
}
print sprintf( "PART2 = %d\n", $start );
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
