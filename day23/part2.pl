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
my $move = 1;

my $cachefile = "sofar.$cups";
if( -e $cachefile ) {
	@c = readfile( $cachefile );
	$move=shift @c;
}
######

my $current = 0;
my $GRABSIZE = 3;
my $LOOPSIZE = scalar @c;
my $t= time();
my $seen = {};
my $parts = {};

my $part = "LOOPDET";
my $ptime = time();
my $last_seen = {};
my $last_reploop = time();
my $reploop = 10000;
my $aoff=0;
while( $move <= 100000000 ) {
	if( $move % $reploop == 1 ){ 
		if( $move % 10000 == 1 ){ 
			open( SF,">", $cachefile);
			print SF "$move\n";
			foreach my $label ( @c ) { print SF "$label\n"; }
			close SF;
			print "**SAVED**\n";
		}


		print "$move ..".(time()-$t)."\n";
		print "cacheloopsize :".(scalar keys %$last_seen)."\n";
		foreach my $p ( sort keys %$parts ) {
			print sprintf( "%20s %f\n", $p, $parts->{$p} );
		}
		$parts = {};

		########################################################################
		$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "CACHE";
		########################################################################
		$last_seen = {};
		my $todo={};
		for my $i (0..$reploop*4) {
			# we expect to be looking for the value of this label minus 1
			$todo->{$c[$i]-1} = 1;
		}
		for(my $i=0; $i<$LOOPSIZE; ++$i ) {
			if( $todo->{$c[$i]} ) {
				$last_seen->{$c[$i]} = $i;
			}
		}
		$aoff=0;
		my $replooptime=time()-$last_reploop;
		$last_reploop=time();
		print "REPLOOP TIME ".sprintf( "%0.2f - secs for 100,000,000 %d or %d hours\n", $replooptime, $replooptime/$reploop*100000000, $replooptime/$reploop*100000000/60/60 );

		########################################################################
		$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "LOOPDET";
		########################################################################
	}

if(0) {
	my $code = join( ",", @c );
	#$code=md5($code);
	if( $seen->{$code} ) { 
		print "LOOP detected\n";
		print "first at: ".$seen->{$code}."\n";
		print "repeat at ".$move."\n";
		exit;
	}
	$seen->{$code} = $move;
}

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "GRAB";
	########################################################################

	# because current is always 0 now we always grab from the right of current
	my @grab = splice( @c, 1, $GRABSIZE );

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "SMARTDEST";
	########################################################################

	my $dest_label = $c[$current]-1;
	if( $dest_label == 0 ) { $dest_label = $LOOPSIZE; }
	while( $dest_label == $grab[0] || $dest_label == $grab[1] || $dest_label == $grab[2] ) {
		$dest_label--;
		if( $dest_label == 0 ) { $dest_label = $LOOPSIZE; }
	}

	# SMARTDEST STARTS HERE

	my $dest;
	if( $last_seen->{$dest_label} ) {
		TRY: for my $try (0..$aoff+1) {
			my $guess = $last_seen->{$dest_label}-$aoff-3*$try;
			if( $guess<@c && $c[$guess] == $dest_label ) {
				$dest = $guess;
				last TRY;
			}
		}
				
		if( !defined $dest ) {
			$parts->{BAD_GUESS}++;
		}
	}
	else {
		$parts->{NO_GUESS}++;
	}
	#print "//$dest_label, $LOOPSIZE\n";

	if( !$dest )  {
		########################################################################
		$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "DUMBDEST";
		########################################################################
		#  find the destination the hard way
	
		for(my $i=0;$i<=@c/2;++$i) {
			if( $c[$i]==$dest_label ) {
				$dest = $i;
				last;
			}
			if( $c[@c-1-$i]==$dest_label ) {
				$dest = @c-1-$i;
				last;
			}
		}
	}

	if( !defined $dest ) { die "oops: $dest_label (".join( ",",@grab); }
	# dest will never be before current as current is zero

	#$parts->{dmin}=$dest if( !defined $parts->{dmin} || $parts->{dmin}>$dest);
	#$parts->{dmax}=$dest if( !defined $parts->{dmax} || $parts->{dmax}<$dest);
	
	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "INSERT";
	########################################################################

	splice( @c, $dest+1,0, @grab);

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "CACHE-IN-LOOP";
	########################################################################
if(0){
	# update to where it'll be AFTER we update current by one
	foreach my $label ( keys %$last_seen ) {
		# everything moves one to the left becuase current moves on
		# if dest was after it's location it also moves 3 more to the left
		if( $last_seen->{$label} < $dest ) {
			$last_seen->{$label}-=3;
		}
	}
}
	# correct grabbed numbers
	$last_seen->{$grab[0]} = $dest+1+$aoff;
	$last_seen->{$grab[1]} = $dest+2+$aoff;
	$last_seen->{$grab[2]} = $dest+3+$aoff;

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "CURRENT";
	########################################################################

	#make it so current is always zero
	# new current is one, but do it by shifting 1 off the start and putting it on the end
	my $front = shift @c;
	push @c, $front;
	$last_seen->{$front} = $LOOPSIZE+$aoff;

	########################################################################
	$parts->{$part}+=time()-$ptime; $ptime = time(); $part = "LOOPDET";
	########################################################################

	$aoff++;
	$move++;
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
