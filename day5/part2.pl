#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );

my $seats = {};
foreach my $row ( @rows ) {
	my $seat = decode( $row );
	$seats->{$seat}=1;	
}
for(my $y=0;$y<128;++$y ) {
	for(my $x=0;$x<8;++$x ) {
		if( $seats->{$y*8+$x} ) {
			print "#";
		} else {
			print "_";
		}
	}
	print " ".$y*8;
	print "\n";
}

exit;

sub decode {
	my( $code ) = @_;
	
	my $row = 0;
	my $col = 0;
	$row+=64 if( substr( $code,0,1 ) eq "B" );
	$row+=32 if( substr( $code,1,1 ) eq "B" );
	$row+=16 if( substr( $code,2,1 ) eq "B" );
	$row+= 8 if( substr( $code,3,1 ) eq "B" );
	$row+= 4 if( substr( $code,4,1 ) eq "B" );
	$row+= 2 if( substr( $code,5,1 ) eq "B" );
	$row+= 1 if( substr( $code,6,1 ) eq "B" );

	$col+= 4 if( substr( $code,7,1 ) eq "R" );
	$col+= 2 if( substr( $code,8,1 ) eq "R" );
	$col+= 1 if( substr( $code,9,1 ) eq "R" );

	#print "$code => $row, $col \n";
	
	return $row*8+$col;
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
