#!/usr/bin/perl
use warnings;
use strict;


my %playlist;
my @poses;
my @argv = @ARGV;
my $was_repeat;
my $bg = 0;


sub usage()
{
	my $out = <<"!";
Usage: $0 [OPT] song1 [song2 [song3...]]
  -f: Fork to background
!
	print STDERR $out;
	exit 1;
}

sub get_playlist()
{
	my %playlist;
	for(map { chomp; $_ } `mpc playlist | nl`){
		die "couldn't parse \"$_\"\n" unless /^\s+([0-9]+)\s+(.*)$/;
		$playlist{$1} = $2;
	}
	return %playlist;
}

sub playing()
{
	return system('mpc status|grep playing > /dev/null') == 0;
}

sub mpc
{
	my $cmd = 'mpc --wait ' . join(' ', @_) . ' > /dev/null';
	my $ret = system $cmd;
	die "$ret = $cmd\n" if $ret;
}

sub pwtest()
{
	my $ret = system "mpc consume off > /dev/null 2>&1";
	return !!$ret;
}

sub escape_regex($)
{
	local $_ = shift;
	s/[][()]/\\&/g;
	$_;
}

sub fin()
{
	# has to be after `stop`
	mpc('single off');
	mpc('repeat on') if $was_repeat;
	exit;
}

# -- start

for(@argv){
	if($_ eq '-f'){
		$bg = 1;
	}else{
		shift @ARGV if $_ eq '--';
		last;
	}
	shift @ARGV;
}

$| = 1;

die "$0: need password\n" if pwtest();

if(@ARGV == 0){
	print STDERR "$0: reading from stdin...\n";
	@ARGV = map { chomp; $_ } <STDIN>;
}

%playlist = get_playlist();
$ARGV[$_] = escape_regex($ARGV[$_]) for 0 .. $#ARGV;

for(@ARGV){
	my $reg = $_;
	my $pos;
	my $num = 0;

	if($reg =~ /^-([0-9]+)$/){
		$pos = $1 + 1;
		$num = 1;
	}else{
		for my $k (keys %playlist){
			if($playlist{$k} =~ m/$reg/i){
				$pos = $k;
				last;
			}
		}
		die "Couldn't find /$reg/ (key)\n" unless $pos;
	}

	push @poses, $pos;

	print "queued \"$playlist{$pos}\" ($pos) for ";
	if($num){
		print "pos " . ($pos - 1 ) . "\n";
	}else{
		print "/$reg/\n";
	}
}

if($bg){
	my $pid = fork();
	die "fork(): $!\n" unless defined $pid;

	if($pid != 0){
		print "forked to background, pid $pid\n";
		exit 0;
	}

	# child only
	close STDOUT;
	close STDERR;
	close STDIN;
	chdir '/';
}

$was_repeat = !!(`mpc | tail -1` =~ /repeat: *on/);

$SIG{INT}  = \&fin;
$SIG{TERM} = \&fin;

for my $pos (@poses){
	mpc('single on');
	mpc('repeat off');
	sleep 1 while playing();

	print "playing $pos ($playlist{$pos})\n" unless $bg;
	mpc("play $pos");
}

fin();
