#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Time::HiRes qw(time);
use Scalar::Util 'refaddr';


my $cups = "643719258";
$cups = "389125467"; # example

my @c = split( //, $cups );
for my $i ( 10..1000000 ) { push @c, $i; }
my $move = 1;

# create loop
my $lookup = [];
my $first = { v=>$c[0] };
$lookup->[$c[0]] = $first;
my $prev = $first;
for( my $i=1;$i<@c;++$i ) {
	my $new = { v=>$c[$i] };
	$prev->{n} = $new;
	$lookup->[$c[$i]]=$new;
	$prev = $new;
}
$prev->{n}=$first;
my $current = $first;

my $MOVES = 100*1000*1000;
my $start_t = time();
my $last_t = time();
while($move<=$MOVES) {
	#print "\n";
	if( ($move % 10000)==1) {
		my $taken = time()-$start_t;
		my $seg = time()-$last_t;
		$last_t = time();
		my $permove = $taken/($move);
		print sprintf( "MOVE %d - total %f, seg %f, permove %f, sec %i, hour %i \n", $move,$taken, $seg, $permove, $permove*$MOVES, $permove*$MOVES/60/60 );
	}
	#report state
	#drawlist( $first, $current );
	
	# grab 3 after current
	my $grab = $current->{n};
	# heal so 1st next after current is what was 4th after current
	$current->{n} = $current->{n}->{n}->{n}->{n};
	# end n of grab3 is now invalid
	$grab->{n}->{n}->{n} = $grab;

	#print "GRAB: ";
	#drawlist($grab);

	my $dest_label = (($current->{v}-2) % @c)+1;	
	while( $dest_label==$grab->{v} || $dest_label==$grab->{n}->{v} || $dest_label==$grab->{n}->{n}->{v} ) {
#print "DL:$dest_label\n";
		$dest_label = (($dest_label-2) % @c)+1;	
	}
	
#	print "Destination: $dest_label\n";
	my $dest = $lookup->[$dest_label];
	my $after_dest = $dest->{n};
	$dest->{n} = $grab;
	$grab->{n}->{n}->{n} = $after_dest;
#	drawlist($first,$current);

	$current = $current->{n};

	$move++;
}
my $a = $lookup->[1]->{n}->{v};
my $b = $lookup->[1]->{n}->{n}->{v};
print "$a x $b = ".($a*$b)."\n";
print "SIZE ".(@$lookup )."\n";
#drawlist( $first, $current );
exit;

sub drawlist {
	my( $head, $current ) = @_;
	my $p=$head;
	while( 1 ) {
		if( defined $current && $p->{v}==$current->{v} ) { print "(";}
		print $p->{v};
		if( defined $current && $p->{v}==$current->{v} ) { print ")";}
		print " ";
		$p = $p->{n};
		last if $p->{v} == $head->{v};
	}
	print "\n";
}
