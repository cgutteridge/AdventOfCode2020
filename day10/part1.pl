#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my @j = sort {$a <=> $b} @rows;
unshift @j, 0;
push @j, $j[-1]+3;
print Dumper( \@j);

my $gaps = {1=>0,2=>0,3=>0};
for( my $i=0;$i<@j-1;$i++ ) {
	my $diff = $j[$i+1]-$j[$i];
	print sprintf( "%i - %i / %i\n", $j[$i], $j[$i+1], $diff );	
	$gaps->{$diff}++;
}
print Dumper( $gaps );
	

print sprintf( "PART1 = %d\n", $gaps->{1}*$gaps->{3});
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
