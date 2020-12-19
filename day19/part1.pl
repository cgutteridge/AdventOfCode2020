#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $rules = {};
my $lists = {};

my @messages = ();
my @rows = readfile( "data" );
my $i=0;
while( $rows[$i] ne "" ) {
	my( $n, $rule ) = split( ": ", $rows[$i] );
	if( $rule =~ m/"(.)"/ ) {
		$lists->{$n}->{$1}=1;
	} else {
		my @opts = split( / \| /, $rule );
		$rules->{$n}=[];
		foreach my $opt ( @opts ) {
			my @v = split( / /, $opt );
			push @{$rules->{$n}}, [@v];
		}
	}
	$i++;
}
$i++; # skip blank
while( $i<scalar @rows ) {
	push @messages, $rows[$i];
	$i++;
}

# v1 try to collapse rules
my @remaining_rules = keys %$rules;
RULE: while( @remaining_rules ) {
	print "RR:".scalar( @remaining_rules)."\n";
	my $rnum = shift @remaining_rules;
	
	foreach my $opt ( @{$rules->{$rnum}} ) {
		foreach my $v ( @{$opt} ) {
			if(!defined $lists->{$v}) {
				push @remaining_rules, $rnum;
				next RULE;
			}
		}
	}

	my $allowed = {};
	$lists->{$rnum} = {};	
	foreach my $opt ( @{$rules->{$rnum}} ) {
		#print Dumper( $opt );
		my @outlist = ("");
		foreach my $v ( @$opt ) {
			my @calist = keys %{$lists->{$v}};
			my @newlist = ();
			foreach my $p1 ( @outlist ) {
				foreach my $p2 ( @calist ) {
					my $newstr = $p1.$p2;
					push @newlist, $newstr;
				}
			}
			@outlist=@newlist;
		}
		#print Dumper( \@outlist );
		foreach my $str ( @outlist ) {
			$lists->{$rnum}->{$str} = 1;
		}
	}	
}
#print Dumper( $lists );
print "--\n";
my $matches = 0;
foreach my $mess ( @messages ) {
	print $mess . " :";
	if( $lists->{0}->{$mess} ) {
		print " MATCH";
		$matches++;
	}
	print "\n";
}
print sprintf( "PART1 = %d\n", $matches );
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
