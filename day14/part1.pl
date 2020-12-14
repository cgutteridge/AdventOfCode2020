#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my @cmds = ();
foreach my $row ( @rows ) {
	#mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
	#mem[8] = 11
	if( $row =~ m/^mask = (.{36})$/ ) {
		push @cmds, [ 'mask',[split //, $1] ];
		next;
	}
	if( $row =~ m/^mem\[(\d+)\] = (\d+)/ ) {
		push @cmds, [ 'mem',$1,$2 ];
		next;
	}
	die;
}
#print Dumper( \@cmds );

my $mem = [];
my $mask;
foreach my $cmd ( @cmds ) {
	if( $cmd->[0] eq "mask" ) {
		$mask = $cmd->[1];
		next;
	}
	# mem then
	my @bits = split( //, sprintf ("%.36b", $cmd->[2]));
	for(my $i=0;$i<36;++$i) {
		$bits[$i]=$mask->[$i] if( $mask->[$i] ne "X" );
	}
	my $num =0;
	my $exp =1;
	for(my $i=35;$i>=0;$i--) {
		$num+=$exp if( $bits[$i] );
		$exp*=2;
	}
	#print $num."\n";
	$mem->[$cmd->[1]] = $num;
}
my $sum = 0;
foreach my $num ( @$mem ) {
	$sum += $num if defined $num;
}

print sprintf( "PART1 = %d\n", $sum );
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
