#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;


my @rows = readfile( "data" );

# rows to a structure
my $tiles = {};
my $tile_n;
while( @rows ) {
	my $title_row=shift @rows;
	my( $ok ) = $title_row=~m/^Tile (\d+):$/;
	if( !$ok ) { die "parse fuckup on title row: $title_row"; }
	$tile_n = $1;
	my $y=0;
	TILE_ROW: while( @rows ) {
		my $tile_row=shift @rows;
		print "TR[$tile_row]\n";
		last TILE_ROW if $tile_row eq "";
		$tiles->{$tile_n}->[$y] = [split //, $tile_row];
		$y++;
	}
}
#print Dumper( $tiles );


my $tile_edges = {};
my $SIZE = 10;
# check tile edges
my $map = {};
foreach my $tile_n ( keys %$tiles ) {
	my $tile = $tiles->{$tile_n};
	my $edge = {"t"=>"","r"=>"","b"=>"","l"=>""};
	for my $i (0..($SIZE-1)) {
		$edge->{t} .= $tile->[0]->[$i];
		$edge->{r} .= $tile->[$i]->[$SIZE-1];
		$edge->{b} .= $tile->[$SIZE-1]->[$SIZE-1-$i];
		$edge->{l} .= $tile->[$SIZE-1-$i]->[0];
	}
	foreach my $e ( qw/ t r b l / ) {
		my $side = $edge->{$e};
		my $rside = reverse $side;
		my @list = ($side,$rside);
		@list = sort @list;
		$side=$list[0];
		push @{ $map->{$side} }, [$tile_n,$e];
		$edge->{$e} = $side;
	}
	print "TILE:$tile_n\n";
	print "\n";
	for my $y ( 0..($SIZE-1) ) {
		for my $x ( 0..($SIZE-1) ) {
			print $tile->[$y]->[$x];
		}
		print "\n";
	}
	print "\n";
	foreach my $e ( qw/ t r b l / ) {
		print "$e : ".$edge->{$e}."\n";
	}
	print "\n";
	$tile_edges->{$tile_n} = $edge;
}
my $counts ={};
foreach my $side ( keys %{$map} ) {
	$counts->{scalar @{$map->{$side}}}++;
}	
print Dumper ( $counts );

my $v = 1;
foreach my $tile_n ( keys %$tiles ) {
	my $tile = $tiles->{$tile_n};
	my $edges = $tile_edges->{$tile_n};
#	print $tile_n." ";
	my $nomatch=0;
	foreach my $e ( keys %$edges ) {
		my $side = $edges->{$e};
		$nomatch++ if (1==scalar @{$map->{$side}});
	}
#	print " - $nomatch\n";
	if( $nomatch == 2 ) { 
		print $tile_n."\n";
		$v *= $tile_n;
	}
}

print "TILECOUNT: ".( scalar keys %$tiles)."\n";


print sprintf( "PART1 = %d\n", $v );
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
