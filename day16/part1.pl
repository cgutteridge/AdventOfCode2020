#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );

my $rules = {};
my $my_ticket = [];
my @tickets = ();

# rules
while( my $row = shift @rows ) {
	last if $row eq "";
	my( $field, $rest ) = split( /: /, $row );
	my @ranges = split( / or /, $rest );
	foreach my $range ( @ranges )  {
		my( $from, $to ) = split( /-/, $range );
		for( my $i=$from;$i<=$to;$i++ ) {
			$rules->{$i}->{$field} = 1;
		}
	}
}

# my ticket
shift @rows; # section label
my $ticket_row = shift @rows;
$my_ticket = [split( /,/, $ticket_row )];
shift @rows; # blank line

# nearby tickets
shift @rows; # section label
while( my $row = shift @rows ) {
	my $ticket = [split( /,/, $row )];
	push @tickets, $ticket;
}

# done reading data
	
my $total = 0;
foreach my $ticket ( @tickets ) {
	foreach my $v ( @$ticket ) {
		$total += $v if( !defined $rules->{$v} );
	}
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
