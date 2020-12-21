#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

#my $xx = [ [1,1,1,1],[0,0,1,1],[0,1,0,1],[1,0,0,1]];
#for my $y (0..3) { print join( "", @{$xx->[$y]} )."\n"; }
#$xx=f($xx);
#for my $y (0..3) { print join( "", @{$xx->[$y]} )."\n"; }
#exit;
my $file = "data";
my @rows = readfile( $file );
my @TRBL = qw/ T R B L /;
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
		#print "TR[$tile_row]\n";
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
foreach my $tile_n ( sort keys %$tiles ) {
	my $tile = $tiles->{$tile_n};
	my $edge = {T=>"",R=>"",B=>"",L=>""};
	for my $i (0..($SIZE-1)) {
		$edge->{T} .= $tile->[0]->[$i];
		$edge->{R} .= $tile->[$i]->[$SIZE-1];
		$edge->{B} .= $tile->[$SIZE-1]->[$SIZE-1-$i];
		$edge->{L} .= $tile->[$SIZE-1-$i]->[0];
	}
	foreach my $e ( @TRBL ) {
		my $side = $edge->{$e};
		my $normside = norm($side);
		push @{ $map->{$normside} }, [$tile_n,$e,$normside ne $side];
		# [ tile number, edge, normalised required flipping ]
		$edge->{$e} = $side;
	}
	#print "TILE:$tile_n\n";
	#print "\n";
	for my $y ( 0..($SIZE-1) ) {
		for my $x ( 0..($SIZE-1) ) {
			#print $tile->[$y]->[$x];
		}
		#print "\n";
	}
	#print "\n";
	foreach my $e ( @TRBL ) {
		#print "$e : ".$edge->{$e}."\n";
	}
	#print "\n";
	$tile_edges->{$tile_n} = $edge;
}
my $counts ={};
foreach my $side ( keys %{$map} ) {
	$counts->{scalar @{$map->{$side}}}++;
}	
#print Dumper ( $counts );

my $tile_type = {};
my $start;
foreach my $tile_n ( sort keys %$tiles ) {
	my $tile = $tiles->{$tile_n};
	my $edges = $tile_edges->{$tile_n};
#	print $tile_n." ";
	my $nomatch=0;
	foreach my $e ( @TRBL ) {
		my $side = $edges->{$e};
		$nomatch++ if (1==scalar @{$map->{norm($side)}});
	}
#	print " - $nomatch\n";
	$tile_type->{$tile_n} = { 0=>"MIDDLE", 1=>"EDGE", 2=>"CORNER" }->{$nomatch};
	if( $nomatch==2 && !defined $start ) { $start = $tile_n; }
}


#print "START: $start\n";
#now we need to make sure the matching edges face right and down...
my $table = {};
# find the matches on this tile 
foreach my $e ( @TRBL ) {
	#print "$e .. ".scalar @{$map->{norm($tile_edges->{$start}->{$e})}};
	#print "\n";
}
# possible modes
# N = natural
# R = right 90
# RR = right 180
# RRR = right 270
# NF = natural, flipped
# RF = right 90, flipped
# RRF = right 180, flipped
# RRRF = right 270, flipped
if( $file eq "ex1" ) {
$table->{0}->{0} = { n=>$start, tile=>r($tiles->{$start}) };
}else{
$table->{0}->{0} = { n=>$start, tile=>r(r($tiles->{$start})) };
}
my $y=0;
my $x=0;
while(1) {
	# next tile is x+1
	# need to get the right edge of the tile to the left
	my $tile = $table->{$y}->{$x}->{tile};
	my $tilen = $table->{$y}->{$x}->{n};
	my $redge = "";
	for my $i (0..$SIZE-1) { $redge .= $tile->[$i]->[$SIZE-1]; }
	my $match;
	my $from;
	my $nflip = norm($redge) eq $redge;
	foreach my $m ( @{$map->{norm($redge)}} ) {
		# tile, ,edge, flipped?
		if( $m->[0] != $tilen ) { $match=$m; } else { $from=$m; }
	}
	if( !$match ) { 
		last;
	}

	# we need to flip the file if one but not both of the edges were flipped by normalisation
	my $mirror=$match->[2] != $nflip;
	#print join( ",",@$match)."..".$tile_type->{$match->[0]}." .. $mirror\n";
#  T    T
# L R  R L   OLD | <-NEW
#  B    B

	my $newtile = $tiles->{$match->[0]};
	if( $match->[1] eq "L" && $mirror==0 ) { $newtile=$newtile; }
	if( $match->[1] eq "B" && $mirror==0 ) { $newtile=r($newtile); }
	if( $match->[1] eq "R" && $mirror==0 ) { $newtile=r(r($newtile)); }
	if( $match->[1] eq "T" && $mirror==0 ) { $newtile=r(r(r($newtile))); }

	if( $match->[1] eq "R" && $mirror==1 ) { $newtile=f($newtile); }
	if( $match->[1] eq "B" && $mirror==1 ) { $newtile=r(f($newtile)); }
	if( $match->[1] eq "L" && $mirror==1 ) { $newtile=r(r(f($newtile))); }
	if( $match->[1] eq "T" && $mirror==1 ) { $newtile=r(r(r(f($newtile)))); }

	$x++;
	$table->{$y}->{$x} = { n=>$match->[0], tile=>$newtile };
}	
my $maxx=$x;
for $x (0..$maxx) {
#print "___$x\n";
	my $y=0;

	while(1) {
		# next tile is x+1
		# need to get the right edge of the tile to the left
		my $tile = $table->{$y}->{$x}->{tile};
		my $tilen = $table->{$y}->{$x}->{n};
		my $redge = "";
		for my $i (0..$SIZE-1) { $redge .= $tile->[$SIZE-1]->[$SIZE-1-$i]; }
		my $match;
		my $from;
		my $nflip = norm($redge) eq $redge;
		foreach my $m ( @{$map->{norm($redge)}} ) {
			# tile, ,edge, flipped?
			if( $m->[0] != $tilen ) { $match=$m; } else { $from=$m; }
		}
		if( !$match ) { 
			last;
#print "BOOOOOO\n";
		}
	
		# we need to flip the file if one but not both of the edges were flipped by normalisation
		my $mirror=$match->[2] != $nflip;
		#print join( ",",@$match)."..".$tile_type->{$match->[0]}." .. $mirror\n";
	#  T    T
	# L R  R L   OLD | <-NEW
	#  B    B
	
		my $newtile = $tiles->{$match->[0]};
		if( $match->[1] eq "T" && $mirror==0 ) { $newtile=$newtile; }
		if( $match->[1] eq "L" && $mirror==0 ) { $newtile=r($newtile); }
		if( $match->[1] eq "B" && $mirror==0 ) { $newtile=r(r($newtile)); }
		if( $match->[1] eq "R" && $mirror==0 ) { $newtile=r(r(r($newtile))); }
	
		if( $match->[1] eq "T" && $mirror==1 ) { $newtile=f($newtile); }
		if( $match->[1] eq "R" && $mirror==1 ) { $newtile=r(f($newtile)); }
		if( $match->[1] eq "B" && $mirror==1 ) { $newtile=r(r(f($newtile))); }
		if( $match->[1] eq "L" && $mirror==1 ) { $newtile=r(r(r(f($newtile)))); }
	
		$y++;
		$table->{$y}->{$x} = { n=>$match->[0], tile=>$newtile };
	}	
}
##print Dumper( $table );
if(0) {
for my $ty ( 0..$maxx ) {
	for my $tx ( 0..$maxx ) {
		print sprintf( "%10d ", $table->{$ty}->{$tx}->{n} );
	}
	print "\n";
	for my $yi ( 0..$SIZE-1 ) { 
		for my $tx ( 0..$maxx ) {
			for my $xi ( 0..$SIZE-1 ) { 
				print $table->{$ty}->{$tx}->{tile}->[$yi]->[$xi];
			}
			print " ";
		}
		print "\n";
	}
	print "\n";
}
}
# SEA MONSTERS
my $sea = [];
for my $ty ( 0..$maxx ) {
	for my $tx ( 0..$maxx ) {
		for my $xi ( 0..7 ) {
			for my $yi ( 0..7 ) {
				$sea->[$ty*8+$yi]->[$tx*8+$xi] = $table->{$ty}->{$tx}->{tile}->[$yi+1]->[$xi+1];
			}
		}
	}
}
my $SEASIZE=$maxx*8+8;
#print Dumper ($sea );

my @seas = (
$sea,
r($sea),
r(r($sea)),
r(r(r($sea))),
f($sea),
r(f($sea)),
r(r(f($sea))),
r(r(r(f($sea)))),
);


my @MONSTER  =( 
"                  # ",
"#    ##    ##    ###",
" #  #  #  #  #  #   ",
);
my @moffs = ();
for my $y ( 0..2 ) {
for my $x ( 0..19 ) {
	if( substr( $MONSTER[$y], $x, 1) eq "#" ) { 
		push @moffs,[$x,$y];
	}
}}
#print Dumper( \@moffs );

print "X:$SEASIZE\n";

foreach my $asea ( @seas ) {
	my $spotted = 0;
	for my $y (0..$SEASIZE-1-3) {
		for my $x (0..$SEASIZE-1-20) {
			# test this offset for seamonsters
			my $ok = 1;
			MOFF: foreach my $moff ( @moffs ) {
				if( $asea->[$y+$moff->[1]]->[$x+$moff->[0]] eq "." ) {
					$ok=0;
					last MOFF;
				}
			}
			if( $ok ) {
				foreach my $moff ( @moffs ) {
					$asea->[$y+$moff->[1]]->[$x+$moff->[0]]="O";
				}
				$spotted++;
			}
		}
	}

	if( $spotted ) {
		foreach my $row ( @{$asea} ) {
			print join( "", @$row)."\n";
		}
		print "\n";
		my $v = 0;
		foreach my $row ( @{$asea} ) {
			foreach my $c ( @$row ) {
				$v++ if $c eq "#";
			}
		}
		print sprintf( "PART2 = %d\n", $v );
		exit;
	}
}

				

	

exit;

sub r {
	my( $tile ) = @_;
	my $tsize = scalar @$tile;

	my $out=[];
	for my $y (0..($tsize-1)) { for my $x (0..($tsize-1)) {
		$out->[$x]->[$tsize-1-$y] = $tile->[$y]->[$x];
	}}
	return $out;
}
sub f {
	my( $tile ) = @_;
	my $tsize = scalar @$tile;

	my $out=[];
	for my $y (0..($tsize-1)) { for my $x (0..($tsize-1)) {
		$out->[$y]->[$tsize-1-$x] = $tile->[$y]->[$x];
	}}
	return $out;
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

# return a version of the side flipped if needed to match 
sub norm {
	my( $side ) = @_;

	my $rside = reverse $side;
	my @list = ($side,$rside);
	@list = sort @list;
	return $list[0];
}

