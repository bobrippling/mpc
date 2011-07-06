#!/usr/bin/perl
use warnings;
use Socket;

sub mpc
{
	my $saddr = inet_aton($MPD_HOST) || die "no host: $MPD_HOST: $!\n";
	my $paddr = sockaddr_in($MPD_PORT, $saddr);
	my $proto = getprotobyname 'tcp';

	socket(SOCK, PF_INET, SOCK_STREAM, $proto) or die "socket(): $!\n";

	connect(SOCK, $paddr) || die "connect(): $!\n";

	syswrite SOCK, "password \"$MPD_PASS\"\n" if length $MPD_PASS;
	syswrite SOCK, "$_\n" for @_;

	my $oks = 2 + @_; # +1 for OK MPD..., +1 for password
	my @lines;

	while(<SOCK>){
		if(/^OK/){
			last if --$oks <= 0;
		}elsif(/^ACK/){
			die "mpd error: $_";
		}else{
			push @lines, $_;
		}
	}

	close SOCK;

	return @lines;
}

sub usage()
{
	print STDERR "Usage: $0 [-v]\n";
	exit 1;
}

my $verbose = 0;

for(@ARGV){
	if($_ eq '-v'){
		$verbose = 1;
	}else{
		usage();
	}
}

$MPD_HOST = $ENV{MPD_HOST} || 'localhost';
$MPD_PORT = $ENV{MPD_PORT} || '6600';
$MPD_PASS = '';


if($MPD_HOST =~ /(.*)@(.*)/){
	$MPD_PASS = $1;
	$MPD_HOST = $2;
}

my @lines = mpc 'status', 'currentsong';

my %opts = (
	# name    => sort-index, char-name, value
	"repeat"  => [0, 'r', 0],
	"random"  => [1, 'z', 0],
	"single"  => [2, 'y', 0],
	"consume" => [3, 'c', 0],
	"xfade"   => [4, 'x', 0],
);

my %mpd;
for(@lines){
	$mpd{$1} = $2 if /^([^ ]+): (.*)/;
}

for my $optk (keys %opts){
	$opts{$optk}->[2] = !!$mpd{$optk} if $mpd{$optk};
}

if($mpd{state} && $mpd{state} eq 'play' || $verbose){
	if(defined $mpd{Title} and defined $mpd{Artist}){
		print $mpd{Title};
		print " - " if length $mpd{Title};
		print $mpd{Artist}, "\n";
	}else{
		print "unknown song\n";
	}
}

for(sort { $a->[0] <=> $b->[0] } values %opts){
	if($_->[2]){
		print $_->[1];
	}else{
		print "-";
	}
}
print "\n";
