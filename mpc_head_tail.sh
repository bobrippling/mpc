#!/bin/sh

usage(){
	echo "Usage: $0 [-peripheral]" >&2
	exit 1
}

set -e

peripheral=5
if [ $# -eq 1 ]
then
	if echo "$1" | grep '^-[0-9]\+$' > /dev/null
	then peripheral=`echo "$1" | sed 's#-\([0-9]\+\)#\1#'`
	else usage
	fi
elif [ $# -ne 0 ]
then usage
fi

nowplaying=`mpc | sed -n 2p | sed 's,.*#\([0-9]\+\)/.*,\1,'`

if [ -z "$nowplaying" ]
then
	echo "$0: Couldn't get now playing" >&2
	exit 1
fi

sedexpr="s#\s*$nowplaying\s*\(.*\)#[1;34m\1[m#; s#^\s*[0-9]\+\s*##"
if ! [ -t 1 ]
then sedexpr=`echo $sedexpr | sed 's/.*; *//'`
fi

mpc playlist | \
	nl | \
	grep -A $peripheral -B $peripheral "^\s*$nowplaying\b" | \
	sed "$sedexpr"
