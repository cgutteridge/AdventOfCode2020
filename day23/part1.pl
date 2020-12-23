#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $cups = "643719258";
#$cups = "389125467"; # example

my @c = split( //, $cups );
my $current = 0;
my $GRABSIZE = 3;
my $LOOPSIZE = scalar @c;
for my $move (1..100)  {
	print "-- move $move --\n";
	print showlist($current, @c );
	my @grab = splice( @c, $current+1, $GRABSIZE );
	my $need = $GRABSIZE-@grab;
	# if we still need some from the front
	if( $need ) {
		push @grab, splice( @c,0, $need);
		$current -= $need;
	}
	#print Dumper ( \@grab, \@c );
	print "Pickup: ".join( ",",@grab)."\n";
	print showlist($current, @c );
	my $dest_label = $c[$current]-1;
	#  find the destination
	my $dest;
	FINDDEST: while(1) {
		if( $dest_label == 0 ) { 
			$dest_label = $LOOPSIZE;
		}
		for(my $i=0;$i<@c;++$i) {
			if( $c[$i]==$dest_label ) {
				$dest = $i;
				last FINDDEST;
			}
		}
		$dest_label--;
	}
	if( $dest < $current ) { 
		$current += 3;
	}
	print "Destination: $dest L=$dest_label\n";
	splice( @c, $dest+1,0, @grab);
	print "\n";
	
	$current = ( $current+1) % $LOOPSIZE;
}
print showlist($current, @c );



my $off;
for( my $i=0;$i<$LOOPSIZE;++$i ){
	$off=$i if $c[$i]==1;
}
my $v="";
my $i=$off;
while(1) {
	$i=($i+1)%$LOOPSIZE;
	last if $i==$off;
	$v.= $c[$i];
}

print sprintf( "PART1 = %s\n", $v );
exit;

sub showlist {
	my( $current, @list ) = @_;

	my $r= "cups: ";
	for(my $i=0;$i<scalar @list;$i++ ) {
		$r.= "(" if( $i==$current);
		$r.= $list[$i];
		$r.= ")" if( $i==$current);
		$r.= " ";
	}
	$r.="\n";
	return $r;
}
	
