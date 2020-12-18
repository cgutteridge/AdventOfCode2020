#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $sum = 0;
my @rows = readfile( "data" );
foreach my $row ( @rows ) {
	my $tree = parse( $row );
	my $v = calc( $tree );
	#print Dumper( $tree );
	print $row." = $v\n";
	$sum += $v;
}
print sprintf( "PART1 = %d\n", $sum );
exit;

sub calc {
	my( $tree ) = @_;

	return $tree->{left} if( $tree->{op} eq "value" );
	
	return calc($tree->{left})+calc($tree->{right}) if( $tree->{op} eq "+" );
	return calc($tree->{left})*calc($tree->{right}) if( $tree->{op} eq "*" );

	die "Bad op: ".$tree->{op};	
}

sub parse {
	my( $string ) = @_;

	$string =~ s/ //g;

	my $chars = [ split( //, $string ) ];
	my $exp = parse_expression( $chars );
	if( @$chars ) {
		die "left over chars at end of '$string': ".join( "", @$chars );
	}
	return $exp;
}

#EXP = VALUE ( [+*] VALUE )*
sub parse_expression {
	my( $chars ) = @_;

	my $exp = parse_value($chars);;

	while( @$chars && $chars->[0] =~ m/^[\*\+]$/ ) {
		my $operator = shift @$chars;
		my $tail_value = parse_value( $chars );
		$exp = { op=>$operator, left=>$exp, right=>$tail_value };
	}

	return $exp;
}
	

#VALUE = '(' EXP ')' 
#      = \d+
sub parse_value {
	my( $chars ) = @_;

	my $exp;

	# expect ( or number
	if( $chars->[0] eq "(" ) {
		shift @$chars; # consume "("
		$exp = parse_expression( $chars );
		if( !@$chars || $chars->[0] ne ")" ) {
			die "expected )";
		}
		shift @$chars; # consume ")"
	} elsif( $chars->[0] =~ m/^\d$/ ) {
		my $numstr = "";
		while( @$chars && $chars->[0] =~ m/^\d$/ ) {
			$numstr .= $chars->[0];
			shift @$chars; # consume digit
		}
		$exp = { op=>"value", left=>$numstr+0 };
	} else {
                die "expected digit or (";
	}
	return $exp;
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
