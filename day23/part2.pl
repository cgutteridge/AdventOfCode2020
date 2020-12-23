#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Time::HiRes qw(time);


my $cups = "643719258";
#$cups = "389125467"; # example

my @c = split( //, $cups );
for my $i ( 10..1000000 ) {
	push @c, $i;
}

my $current = 0;
my $GRABSIZE = 3;
my $LOOPSIZE = scalar @c;
my $t= time();
my $seen = {};
my $parts = {};

my $part = "LOOPDET";
my $ptime = time();
my $last_seen = {};
for my $move (1..1000000000)  {
	if( $move % 100 == 1 ){ 
		print "$move ..".(time()-$t)."\n";
		foreach my $p ( sort keys %$parts ) {
			print sprintf( "%10s %f\n", $p, $parts->{$p} );
		}

		$lookahead = {};
		my $todo={};
		for my $i (1..100) {
			# we expect to be looking for the value of this label minus 1
			$todo->{$c[$i]-1} = 1;
		}
		for(my $i=1; $i<$LOOPSIZE; ++$i ) {
			if( $todo->{$c[$i]} ) {
				$lookahead->{$c[$i]} = $i;
			}
		}
	}
	my $code = md5(join( ",", @c ));
	if( $seen->{$code} ) { 
		print "LOOP detected\n";
		print "first at: ".$seen->{$code}."\n";
		print "repeat at ".$move."\n";
		exit;
	}
	$seen->{$code} = $move;

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "GRAB";
	########################################################################

	# because current is always 0 now we always grab from the right of current
	my @grab = splice( @c, 1, $GRABSIZE );
	my $lookahead_offset = -3;

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "DEST";
	########################################################################

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

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "CACHE";
	########################################################################
	foreach my $label ( keys %$lastseen ) {
		# everything moves one to the left becuase current moves on
		# if dest was after it's location it also moves 3 more to the left
		if( $lastseen->{$label} < $dest ) {
			$lastseen->{$label}-=4;
		} else {
			$lastseen->{$label}-=1;
		}
	}

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "INSERT";
	########################################################################

	#print "Destination: $dest L=$dest_label\n";
	splice( @c, $dest+1,0, @grab);
	#print "\n";
	
	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "CURRENT";
	########################################################################

	#make it so current is always zero
	# new current is one, but do it by shifting 1 off the start and putting it on the end
	my $front = shift @c;
	push @c, $front;

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "LOOPDET";
	########################################################################
}
#print showlist($current, @c );
for my $i (0..$LOOPSIZE-1 ) {
	if( $c[$i]==1 ) {
		for my $off (0..2 ) {
			print sprintf( "%d .. %d\n", $i+$off, $c[$i+$off] );
		}
		print "TIME=".(time()-$t)."\n";
		exit;
	}
}

#print sprintf( "PART1 = %s\n", $v );
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
	
