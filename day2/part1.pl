#!/usr/bin/perl

use Data::Dumper;
use strict;
use warnings;

my $valid_count = 0;
my @rows = readfile( "data" );
foreach my $row ( @rows ) {
	# 1-3 a: abcde
	my $ok = $row =~ m/^(\d+)-(\d+) (.): (.*)$/;
	if( !$ok ) { die "failed to parse $row"; }
	my( $min,$max,$char,$pass ) = ($1,$2,$3,$4);
	my $counts = {};
	$counts->{$char} = 0;
	foreach my $c ( split( //, $pass ) ) {
		$counts->{$c}++;
	}
	if( $counts->{$char} >= $min && $counts->{$char} <= $max ) { $valid_count++; }
}
print "$valid_count\n";

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
