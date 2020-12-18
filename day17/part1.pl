#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my $cube = {};
my $size = {
	xmin=>0,
	ymin=>0,
	zmin=>0,
	zmax=>0,
	ymax=>scalar @rows-1,
	xmax=>length($rows[0])-1,
};
for( my $y=0;$y<=$size->{ymax};++$y ) {
	for( my $x=0;$x<=$size->{xmax};++$x ) {
		$cube->{0}->{$y}->{$x} = substr( $rows[$y], $x, 1) eq "#";	
	}
}

draw();
for my $cycle ( 1..6 ) {
	my $newcube = {};
	$size= { 
		xmin=>$size->{xmin}-1,
		ymin=>$size->{ymin}-1,
		zmin=>$size->{zmin}-1,
		xmax=>$size->{xmax}+1,
		ymax=>$size->{ymax}+1,
		zmax=>$size->{zmax}+1,
	};

	for(my $z=$size->{zmin};$z<=$size->{zmax};++$z) {
	for(my $y=$size->{ymin};$y<=$size->{ymax};++$y ) {
	for(my $x=$size->{xmin};$x<=$size->{xmax};++$x ) {
		# count neighbours
		my $n=0;
		for(my $z2=$z-1;$z2<=$z+1;++$z2) {
		next if $z2<$size->{zmin};
		next if $z2>$size->{zmax};
		for(my $y2=$y-1;$y2<=$y+1;++$y2) {
		next if $y2<$size->{ymin};
		next if $y2>$size->{ymax};
		for(my $x2=$x-1;$x2<=$x+1;++$x2) {
		next if $x2<$size->{xmin};
		next if $x2>$size->{xmax};
			next if $x2==$x && $y2==$y && $z2==$z;
			$n++ if( $cube->{$z2}->{$y2}->{$x2} );	
		}}}
		if( $cube->{$z}->{$y}->{$x} ) {
			$newcube->{$z}->{$y}->{$x} = $n==2 || $n==3;
		} else {
			$newcube->{$z}->{$y}->{$x} = $n==3;
		}
	}}}
	$cube = $newcube;
	#print "CYCLE = $cycle\n";	
	#draw();
}	

my $active=0;
for(my $z=$size->{zmin};$z<=$size->{zmax};++$z) {
	for( my $y=$size->{ymin};$y<=$size->{ymax};++$y ) {
		for( my $x=$size->{xmin};$x<=$size->{xmax};++$x ) {
			$active++ if ($cube->{$z}->{$y}->{$x});
}}}
print sprintf( "PART1 = %d\n", $active );

exit;

sub draw {	
print Dumper($size);
for(my $z=$size->{zmin};$z<=$size->{zmax};++$z) {
	print "\nz=$z\n";
	for( my $y=$size->{ymin};$y<=$size->{ymax};++$y ) {
		for( my $x=$size->{xmin};$x<=$size->{xmax};++$x ) {
			print ($cube->{$z}->{$y}->{$x}?"#":".");
		}
		print "\n";
	}
}
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
