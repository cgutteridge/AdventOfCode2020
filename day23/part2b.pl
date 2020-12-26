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
my @next = ();
my $first = $c[0];
my $prev = $first;
for( my $i=1;$i<@c;++$i ) {
	$next[$prev] = $c[$i];
	$prev = $c[$i];
}
$next[$prev] = $first;

my $current = $first;
my $MOVES = 10*1000*1000;
my $start_t = time();
while($move<=$MOVES) {
	my $grab = $next[$current];
	my $grab_end = $next[$next[$grab]];
	$next[$current] = $next[$next[$next[$grab]]];

	my $dest_label = (($current-2) % @c)+1;	
	while( $dest_label==$grab || $dest_label==$next[$grab] || $dest_label==$next[$next[$grab]] ) {
		$dest_label = (($dest_label-2) % @c)+1;	
	}
	
	my $after_dest = $next[$dest_label];
	$next[$dest_label]=$grab;
	$next[$next[$next[$grab]]]=$after_dest;

	$current = $next[$current];

	$move++;
}
my $taken = time()-$start_t;
print sprintf( "MOVE %d - total %f\n", $move,$taken);
my $a = $next[1];
my $b = $next[$a];
print "$a x $b = ".($a*$b)."\n";
