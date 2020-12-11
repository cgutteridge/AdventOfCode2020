#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my $g = [];
my $h = scalar @rows;
for( my $y=0;$y<$h;$y++ ) {
	$g->[$y] = [split( //, $rows[$y] )];
}
my $w = scalar @{$g->[0]};

my $state = $g;
while(1) {
	my $changed = 0;
	my $new_state = [];
	for( my $y=0; $y<$h; $y++ ) {
		for( my $x=0; $x<$w; $x++ ) {
			if( $state->[$y]->[$x] eq "." ) {
				#print ".";
				$new_state->[$y]->[$x] = ".";
				next;
			}
			my $adj = 0;
			foreach my $yi ( -1,0,1 ) {
				my $yc = $y+$yi;
				next if $yc<0;
				next if $yc>$h-1;
				foreach my $xi ( -1,0,1 ) {
					next if $xi==0 && $yi==0; # don't check the focus seat
					my $xc = $x+$xi;
					next if $xc<0;
					next if $xc>$w-1;
					if( $x==0 && $y==0 ) {
						#print "Adj?: $xc,$yc - $xi,$yi\n";
					}
					$adj++ if( $state->[$yc]->[$xc] eq "#" );
				}
			}
			#print $adj;
			if( $state->[$y]->[$x] eq "L" ) {
				if( $adj == 0 ) { 
					$new_state->[$y]->[$x] = "#";
					$changed = 1;
				} else {
					$new_state->[$y]->[$x] = "L";
				}
			}
			if( $state->[$y]->[$x] eq "#" ) {
				if( $adj >= 4 ) { 
					$new_state->[$y]->[$x] = "L";
					$changed = 1;
				} else {
					$new_state->[$y]->[$x] = "#";
				}
			}
		}
		#print "\n";
	}
	for( my $y=0;$y<$h; ++$y ) {
		print join( "",@{$new_state->[$y]} )."\n";
	}
	print "\n";
	last unless $changed;
	$state = $new_state;
}

my $count = 0;	
for( my $y=0;$y<$h; ++$y ) {
	for( my $x=0;$x<$w; ++$x ) {
		$count++ if $state->[$y]->[$x] eq "#";
	}
}

print sprintf( "PART1 = %d\n", $count );
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
