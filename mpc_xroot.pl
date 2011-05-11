#!/usr/bin/perl
use warnings;

sub usage()
{
	die "Usage: $0 [-n]\n";
}

my $n = '';

if(@ARGV == 1){
	usage unless $ARGV[0] =~ /^(-[0-9.]+)$/;
	$n = $1;
}elsif(@ARGV != 0){
	usage;
}

my ($first, $stat) = map { chomp; $_ } `mpc_status.pl`;

exec "echo '$first [$stat]' | dwm_xroot.sh $n";
