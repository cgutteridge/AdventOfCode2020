#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @rows = readfile( "data" );
my @code = ();
foreach my $row (@rows) {
	my( $cmd, $v ) = split( / /, $row );
	$v=~s/\+//;
	push @code, [$cmd,$v];
}
#print Dumper( \@code );

for(my $i=0;$i<@code;++$i ) {
	next if $code[$i]->[0] eq "acc";
#	print "**$i\n";
	my @new = @code;
	if( $code[$i]->[0] eq "jmp" ) {
		$new[$i] = [ "nop", $code[$i]->[1] ];
	} else {
		$new[$i] = [ "jmp", $code[$i]->[1] ];
	}
	my $r= runcode( @new );
	if( $r->[0] ) { 	
		print sprintf( "PART2 = %d\n", $r->[1] );
		exit;	
	}
}


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

sub runcode {
	my( @code ) = @_;

	my $acc = 0;
	my $step = 0;
	my $done ={};
	while(1) {
		if( $done->{$step} ) { 
			return [0];
		}
		$done->{$step}=1;
		my $cmd = $code[$step];
		if( !defined $cmd ) {
			return [1,$acc];
		}
		#print  "$step .. ".$code[$step]->[0]." .. ".$code[$step]->[1]." ... ($acc)\n";
		if( $cmd->[0] eq "nop" ) {
			#
		}
		if( $cmd->[0] eq "acc" ) {
			$acc += $cmd->[1];
		}
		if( $cmd->[0] eq "jmp" ) {
			$step += $cmd->[1];
			next;
		}
		$step++;
	}
}
	

