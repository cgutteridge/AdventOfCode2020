#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my @code = ();
foreach my $row (@rows) {
	my( $cmd, $v ) = split( / /, $row );
	$v=~s/\+//;
	push @code, [$cmd,$v];
}
print Dumper( \@code );

my $acc = 0;
my $step = 0;
my $done ={};
while(1) {
	if( $done->{$step} ) { 
		last;
	}
	$done->{$step}=1;
	my $cmd = $code[$step];
	print  "$step .. ".$code[$step]->[0]." .. ".$code[$step]->[1]." ... ($acc)\n";
	if( $cmd->[0] eq "nop" ) {
		#
	}
	if( $cmd->[0] eq "acc" ) {
		$acc += $cmd->[1];
	}
	if( $cmd->[0] eq "jmp" ) {
		$step += $cmd->[1];
		next;
	}
	$step++;
}
	

print sprintf( "PART1 = %d\n", $acc );

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
