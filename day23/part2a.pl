#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Time::HiRes qw(time);
use Scalar::Util 'refaddr';


my $cups = "643719258";
#$cups = "389125467"; # example

my @c = split( //, $cups );
for my $i ( 10..1000000 ) { push @c, $i; }
my $move = 1;

# create loop
my $lookup = [];
my $first = [ undef, $c[0] ];
$lookup->[$c[0]] = $first;
my $prev = $first;
for( my $i=1;$i<@c;++$i ) {
	my $new = [ undef, $c[$i] ];
	$prev->[0] = $new;
	$lookup->[$c[$i]]=$new;
	$prev = $new;
}
$prev->[0]=$first;
my $current = $first;

my $MOVES = 10*1000*1000;
my $start_t = time();
my $last_t = time();
while($move<=$MOVES) {
	#print "\n";
	if( ($move % 100000)==1) {
		my $taken = time()-$start_t;
		my $seg = time()-$last_t;
		$last_t = time();
		my $permove = $taken/($move);
		print sprintf( "MOVE %d - total %f, seg %f, permove %f, sec %i, remain sec %i \n", $move,$taken, $seg, $permove, $permove*$MOVES, $permove*($MOVES-$move));
	}
	#report state
	#drawlist( $first, $current );
	
	# grab 3 after current
	my $grab = $current->[0];
	# heal so 1st next after current is what was 4th after current
	$current->[0] = $current->[0]->[0]->[0]->[0];
	# end n of grab3 is now invalid
	$grab->[0]->[0]->[0] = $grab;

	#print "GRAB: ";
	#drawlist($grab);

	my $dest_label = (($current->[1]-2) % @c)+1;	
	while( $dest_label==$grab->[1] || $dest_label==$grab->[0]->[1] || $dest_label==$grab->[0]->[0]->[1] ) {
#print "DL:$dest_label\n";
		$dest_label = (($dest_label-2) % @c)+1;	
	}
	
#	print "Destination: $dest_label\n";
	my $dest = $lookup->[$dest_label];
	my $after_dest = $dest->[0];
	$dest->[0] = $grab;
	$grab->[0]->[0]->[0] = $after_dest;
#	drawlist($first,$current);

	$current = $current->[0];

	$move++;
}
my $a = $lookup->[1]->[0]->[1];
my $b = $lookup->[1]->[0]->[0]->[1];
print "$a x $b = ".($a*$b)."\n";
print "SIZE ".(@$lookup )."\n";
#drawlist( $first, $current );
exit;

sub drawlist {
	my( $head, $current ) = @_;
	my $p=$head;
	while( 1 ) {
		if( defined $current && $p->[1]==$current->[1] ) { print "(";}
		print $p->[1];
		if( defined $current && $p->[1]==$current->[1] ) { print ")";}
		print " ";
		$p = $p->[0];
		last if $p->[1] == $head->[1];
	}
	print "\n";
}
