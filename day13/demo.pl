#!/usr/bin/perl -w

my $A=11;
my $B=3;
my $C=10;
for(my $x=0;$x<$C;$x++ ) {
	print sprintf( "(%ix%i+%i)%%%i=%i\n", $A,$x, $B, $C, ($A*$x+$B)%$C );
}
