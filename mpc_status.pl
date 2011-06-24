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

	syswrite SOCK, "$_\n" for @_;

	my $oks = 1 + @_; # +1 for OK MPD...
	my @lines;

	while(<SOCK>){
		if(/^OK/){
			if(--$oks <= 0){
				return @lines;
			}
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

$MPD_HOST = $1 if $MPD_HOST =~ /@(.*)/;

my @lines = mpc 'status', 'currentsong';

my %opts = (
	"repeat"  => ['r', 0],
	"random"  => ['z', 0],
	"single"  => ['y', 0],
	"consume" => ['c', 0],
	"xfade"   => ['x', 0],
);

my %mpd;
for(@lines){
	$mpd{$1} = $2 if /^([^ ]+): (.*)/;
}


for my $mpdk (keys %mpd){
	for my $optk (keys %opts){
		$opts{$optk}->[1] = !!$mpd{$mpdk} if $optk eq $mpdk;
	}
}

if($mpd{state} eq 'play' || $verbose){
	if(defined $mpd{Title} and defined $mpd{Artist}){
		print $mpd{Title};
		print " - " if length $mpd{Title};
		print $mpd{Artist}, "\n";
	}else{
		print "unknown song\n";
	}
}

for(sort values %opts){
	if($_->[1]){
		print $_->[0];
	}else{
		print "-";
	}
}
print "\n";
