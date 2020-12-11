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
				XI: foreach my $xi ( -1,0,1 ) {
					next if( $xi == 0 && $yi==0 );
					my $steps = 1;
					# ++ adj if we see a # before a L or go off the edge
					while( $x+$xi*$steps >=0 
					    && $x+$xi*$steps <$w
					    && $y+$yi*$steps >=0
					    && $y+$yi*$steps <$h ) {
						if( $state->[$y+$yi*$steps]->[$x+$xi*$steps] eq "#" ) {
							$adj++;
							next XI;
						}
						if( $state->[$y+$yi*$steps]->[$x+$xi*$steps] eq "L" ) {
							next XI;
						}
						$steps++;
					}
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
				if( $adj >= 5 ) { 
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
