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

my @valid_tickets = ();
foreach my $ticket ( @tickets ) {
	my $valid = 1;
	foreach my $v ( @$ticket ) {
		$valid = 0 if( !defined $rules->{$v} );
	}
	push @valid_tickets, $ticket if $valid;
}

# work out labels

my $cols = scalar @$my_ticket;
my @cols_to_solve = ();
for my $i (0..$cols-1) { push @cols_to_solve, $i; }

my $field2col = {};
COL: while( @cols_to_solve ) {
	my $col = shift @cols_to_solve;
	my $couldbe;
	TICKET: foreach my $ticket ( @valid_tickets ) {
		my $v = $ticket->[$col];
		my $new_couldbe = {};
		if( !defined $couldbe ) {
			# only initialise with things it could be, so not stuff 	
			# in field2col
			foreach my $field ( keys %{$rules->{$ticket->[$col]}} ) {
				$new_couldbe->{$field} = 1 if( !defined $field2col->{$field} );
			}
		}
		else {
			foreach my $field ( keys %{$rules->{$ticket->[$col]}} ) {
				$new_couldbe->{$field} = 1 if $couldbe->{$field};
			}
		}
		$couldbe = $new_couldbe;
		if( scalar keys %$couldbe == 0 ) {
			die "BUGGER";
		}
		if( scalar keys %$couldbe == 1 ) {
			my $field = ( keys %$couldbe )[0];
			$field2col->{$field} = $col;
			next COL;
		}
	}
	# got to end and there's still more than one possibility, try this again later
	push @cols_to_solve, $col;
	#print "$col has multiple options, try again later\n";
}

print Dumper( $field2col );

my $total = 1;
foreach my $field ( keys %$field2col ) {
	if( $field =~ m/^departure /) {
		my $v = $my_ticket->[$field2col->{$field}];
		print $v."\n";
		$total *= $v;
	}
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
