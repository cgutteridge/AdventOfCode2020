#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
my $file= "data";
my @rows = readfile( $file );
my @products = ();
# mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
foreach my $row ( @rows ) {
	$row=~s/\)//;
	my( $ingtext, $altext ) = split( / \(contains /, $row );
	my $p = { ings =>[split / /, $ingtext], als=>[split /, /, $altext] };
	push @products,$p;
}

my $ings = {};
foreach my $p ( @products ) {
	foreach my $i ( @{$p->{ings}} ) {
		$ings->{$i}++;
	}
}

my $al_could_be={};
foreach my $p ( @products ) {
	foreach my $a ( @{$p->{als}} ) {
		my $could_be = {};
		if( !defined $al_could_be->{$a} ) {
			foreach my $i ( @{$p->{ings}} ) {
				$could_be->{$i} = 1;
			}
		} else {
			foreach my $i ( @{$p->{ings}} ) {
				$could_be->{$i} = 1 if( $al_could_be->{$a}->{$i} );
			}
		}
		$al_could_be->{$a}=$could_be;
		
	}
}

foreach my $a ( keys %{$al_could_be} ) {
	foreach my $i ( keys %{$al_could_be->{$a}} ) {
		delete $ings->{$i};
	}
}

my $known = {};
while( %{$al_could_be} ) {
	# find a known one, remove it to the known list and trim the others of it
	my $found_al;
	AL: foreach my $a ( keys %{$al_could_be} ) {
		if( scalar keys %{$al_could_be->{$a}} == 1 ) {
			$found_al = $a;
			last AL;
		}
	}
	if( !defined $found_al ) {
		die "stuck";
	}
	my $found_ing = ( keys %{$al_could_be->{$found_al}}  )[0];
	$known->{$found_al} = $found_ing;

	delete $al_could_be->{$found_al};
	AL: foreach my $a ( keys %{$al_could_be} ) {
		delete $al_could_be->{$a}->{$found_ing};
	}
}
	
print Dumper( $al_could_be );
print Dumper( $known );
my @list = ();
foreach my $a ( sort keys %$known ) {
	push @list, $known->{$a};
}

print sprintf( "PART2 = %s\n", join(",",@list) );
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
