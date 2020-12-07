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
	my( $pos1,$pos2,$char,$pass ) = ($1,$2,$3,$4);
	my $c1 = substr( $pass, $pos1-1, 1 );
	my $c2 = substr( $pass, $pos2-1, 1 );

	if( ( $c1 eq $char && $c2 ne $char ) || ( $c1 ne $char && $c2 eq $char ) ) {
		$valid_count++;
	}
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
