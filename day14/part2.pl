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

my $mem = {};
my $mask;
foreach my $cmd ( @cmds ) {
print "-\n";
	if( $cmd->[0] eq "mask" ) {
		$mask = $cmd->[1];
		next;
	}


	# address to binary
	my @bits = split( //, sprintf ("%.36b", $cmd->[1]));
print Dumper( $cmd );
	#print join( "", @bits )."\n";
	my @floating  = ();
	for(my $i=0;$i<36;++$i) {
		$bits[$i]=1 if( $mask->[$i] eq "1" );
		push @floating, $i if( $mask->[$i] eq "X" );
	}

	my @opts = expand_floating( \@bits, @floating );
	foreach my $opt ( @opts ) {
		print join( "", @$opt )."\n";

		my $num =0;
		my $exp =1;
		for(my $i=35;$i>=0;$i--) {
			$num+=$exp if( $opt->[$i] );
			$exp*=2;
		}
		#print "WRITe TO ".$num."\n";
		$mem->{$num} = $cmd->[2];
	}
}
my $sum = 0;
foreach my $adr ( keys %$mem ) {
	$sum += $mem->{$adr};
}

print sprintf( "PART2 = %d\n", $sum );
exit;

sub expand_floating {
	my( $bits, @floaters ) = @_;

	print "EF: ".join("",@$bits)." ".join( ",",@floaters)."\n";

	if( scalar @floaters == 0 ) {
		return ( \@$bits );
	} 
	my $floater = shift @floaters;
	my @sublist = expand_floating( $bits, @floaters );
	my @results = ();
	for my $b (0..1) {
		foreach my $v ( @sublist ) {
			my @newv = @$v;
			$newv[$floater]=$b;
			push @results, \@newv;
		}
	}	
	return @results;
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
