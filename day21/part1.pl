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
print Dumper( \@products );

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
print Dumper( $al_could_be );

foreach my $a ( keys %{$al_could_be} ) {
	foreach my $i ( keys %{$al_could_be->{$a}} ) {
		delete $ings->{$i};
	}
}

print Dumper( $ings );
my $v = 0;
foreach my $i ( keys %$ings ) {
	$v+=$ings->{$i}
}
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
