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
my $maxm = 0;
while( $i<scalar @rows ) {
	push @messages, $rows[$i];
	$maxm=length($rows[$i]) if( length( $rows[$i] ));
	$i++;
}
print "MAX MESSAGE $maxm\n";

#8: 42*

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
my $D=0;
		foreach my $v ( @$opt ) {
$D++;
print "Depth:$D\n";
			my @calist = keys %{$lists->{$v}};
			my @newlist = ();
			foreach my $p1 ( @outlist ) {
				foreach my $p2 ( @calist ) {
					# no point worrying about legal values longer than our longest message
					my $ok = 0;
					my $newstr = $p1.$p2;
					if( length( $newstr )<=$maxm ) {
						MESS: foreach my $mess ( @messages ) {
							if( $mess=~m/$newstr/ ) {
								$ok = 1;
								last MESS;
							}
						}
						if( $ok ) {
							push @newlist, $newstr;
						}
					}
				}
			}
			@outlist=@newlist;
		}
		#print Dumper( \@outlist );
		foreach my $str ( @outlist ) {
			$lists->{$rnum}->{$str} = 1;
		}
	}	
	#if( $rnum == 42 ) { print Dumper( $lists->{$rnum} ); }
}
foreach my $i42 ( keys %{$lists->{42}} ) {
	if( defined $lists->{31}->{$i42} ) {
		die "dang $i42";
	}
}
# ok so 42 & 31 don't intersect
print Dumper( $lists->{42}, $lists->{31} );

print "--\n";
my $matches = 0;
MESS: foreach my $mess ( @messages ) {
	print $mess . " :";
	print "(".length( $mess).") ";
	if( $lists->{0}->{$mess} ) { print " OLDMATCH"; }
	my @chunks = ();
	for(my $i=0;$i<length($mess);$i+=8 ) {
		push @chunks, substr( $mess,$i,8);
	}

	# need 2+X then 1+Y and X must be bigger or equal to Y+1 (minimum is XXY)
	my $r = "";
	my $X=0; #42
	my $Y=0; #31
	foreach my $c ( @chunks ) {
		# if we get a X(42) after and Y(31) then it's invalid
		if( $lists->{42}->{$c} ) { $r .= "X"; $X++; if( $Y>0) { print "- FAIL Y BEFORE X -- $r\n"; next MESS; } }
		elsif( $lists->{31}->{$c} ) { $r .= "Y" ; $Y++; }
		else { next MESS; }
	}

	# needs to match an 8 then an 11
	# which means 42* followed by x 42s then  x31s

	# aka
	# any 1+ of 42 then 1+ of 31 but not more 31 than 42.

	print " - $r";
	if( $X<$Y+1 ) {
		print " Failed $X<$Y+1\n";
		next MESS ;
	}
	if( $Y == 0 ) {
		print " Failed $Y is 0\n";
		next MESS ;
	}
	$matches++;
	print " - MATCH\n";
}
print sprintf( "PART2 = %d\n", $matches );
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
