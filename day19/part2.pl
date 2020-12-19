#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $rules = {};
my $lists = {};

my @messages = ();
my @rows = readfile( "ex2" );
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
#11: 42 31 | 42 42 31 31 | 42 42 42 31 31 31  etc.
# create fake rules to resolve these when 42 & 31 are known
$rules->{8}=[
	[42],
	[42,42],
	[42,42,42],
	[42,42,42,42],
	[42,42,42,42,42],
	[42,42,42,42,42,42],
	[42,42,42,42,42,42,42],
	[42,42,42,42,42,42,42,42],
	[42,42,42,42,42,42,42,42,42],
	[42,42,42,42,42,42,42,42,42,42],
];
$rules->{11}=[
[42,31],
[42,42,31,31],
[42,42,42,31,31,31],
[42,42,42,42,31,31,31,31],
[42,42,42,42,42,31,31,31,31,31],
];

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
