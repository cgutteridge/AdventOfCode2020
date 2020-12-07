#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @req_fields = qw/ byr iyr eyr hgt hcl ecl pid /;

my @rows = readfile( "data" );
my @passports = ();
my $passport = {};
foreach my $row ( @rows ) {
	if( $row eq "" ) {
		push @passports, $passport;
		$passport = {};
		next;
	}
	foreach my $kv ( split / /, $row ) {
		my( $k, $v ) = split( /:/, $kv );
		$passport->{$k} = $v;
	}
}
push @passports, $passport;

my $total = 0;
foreach my $passport ( @passports ) {
	my $ok = 1;
	foreach my $f ( @req_fields ) {
		if( !defined $passport->{$f} ) {
			$ok = 0;
			last;
		}
	}
#print Dumper( $passport,$ok);

	$total++ if $ok;
}
print "PART1=$total\n";

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
