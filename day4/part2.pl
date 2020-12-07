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
PASS: foreach my $passport ( @passports ) {
	foreach my $f ( @req_fields ) {
		if( !defined $passport->{$f} ) {
			next PASS;
		}
	}

	next unless( $passport->{byr} =~ m/^\d\d\d\d$/ );
	next unless( $passport->{byr} >= 1920 && $passport->{byr} <= 2002 );

	next unless( $passport->{iyr} =~ m/^\d\d\d\d$/ );
	next unless( $passport->{iyr} >= 2010 && $passport->{iyr} <= 2020 );

	next unless( $passport->{eyr} =~ m/^\d\d\d\d$/ );
	next unless( $passport->{eyr} >= 2020 && $passport->{eyr} <= 2030 );

	my $h_ok = $passport->{hgt} =~ m/^(\d+)(cm|in)$/;
	next unless $h_ok;
	my( $hgt, $unit ) = ( $1,$2 );
	if( $unit eq "cm" ) {
		next unless( $hgt >= 150 && $hgt <= 193 );
	}
	if( $unit eq "in" ) {
		next unless( $hgt >= 59 && $hgt <= 76 );
	}

	next unless( $passport->{hcl} =~ m/^#[0-9a-f]{6}$/ );

	next unless( $passport->{ecl} =~ m/^(amb|blu|brn|gry|grn|hzl|oth)$/ );

	next unless( $passport->{pid} =~ m/^\d{9}$/ );

      	#cid (Country ID) - ignored, missing or not.

	$total++;
}
print "PART2=$total\n";

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
