#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $cups = "643719258";
$cups = "389125467"; # example

my @c = split( //, $cups );
my $current = 0;
my $GRABSIZE = 3;
my $LOOPSIZE = scalar @c;
my $seen = {};
for my $move (1..100)  {
	my $code = md5(join( ",", @c ));
	if( $seen->{$code} ) { 
		print "LOOP detected\n";
		print "first at: ".$seen->{$code}."\n";
		print "repeat at ".$move."\n";
		exit;
	}
	$seen->{$code} = $move;
	#print "-- move $move --\n";
	print showlist($current, @c );
	my @grab = splice( @c, $current+1, $GRABSIZE );

	# because current is always 0 now we always grab from the right of current

	#print Dumper ( \@grab, \@c );
	#print "Pickup: ".join( ",",@grab)."\n";
	#print showlist($current, @c );
	my $dest_label = $c[$current]-1;
	if( $dest_label == 0 ) { $dest_label = $LOOPSIZE; }
	while( $dest_label == $grab[0] || $dest_label == $grab[1] || $dest_label == $grab[2] ) {
		$dest_label--;
		if( $dest_label == 0 ) { $dest_label = $LOOPSIZE; }
	}
	
	#print "//$dest_label, $LOOPSIZE\n";

	#  find the destination
	my $dest;
	for(my $i=0;$i<@c;++$i) {
		if( $c[$i]==$dest_label ) {
			$dest = $i;
			last;
		}
	}
	if( !defined $dest ) { die "oops: $dest_label (".join( ",",@grab); }
	# dest will never be before current as current is zero

	#print "Destination: $dest L=$dest_label\n";
	splice( @c, $dest+1,0, @grab);
	#print "\n";
	
	#make it so current is always zero
	# new current is one, but do it by shifting 1 off the start and putting it on the end
	my $front = shift @c;
	push @c, $front;
}
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
	
