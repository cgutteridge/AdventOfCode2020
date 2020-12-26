#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @data = qw/ 11404017 13768789 /; # puzzle
#@data = qw/5764801 17807724 /;

my $subject = 7;
my $value = 1;
my $match;
my $loopsize;
for my $step (1..1000000000) {
	if( $step % 1000000 == 0 ){ print "STEP $step\n";}
	$value = ( $value * $subject ) % 20201227;
	if( $value == $data[0] ) {
		$match = 0;
		$loopsize = $step;
		print sprintf( "step %10i value %10i\n", $step, $value );
		last;
	}
	if( $value == $data[1] ) {
		$match = 1;
		$loopsize = $step;
		print sprintf( "step %10i value %10i\n", $step, $value );
		last;
	}
}
if( !defined $match ) {
	print "boo\n";
	exit;
}

# do that many loops with the other ones key
$subject = $data[ 1-$match ];
$value = 1;
for my $step (1..$loopsize) {
	$value = ( $value * $subject ) % 20201227;
}
print "$value\n";




#print sprintf( "PART1 = %d\n", $black);
exit;
