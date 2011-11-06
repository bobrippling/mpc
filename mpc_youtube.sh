#!/bin/sh

if [ "$1" = '-n' ]
then
	BROWSER=echo
	shift
elif [ $# -ne 0 ]
then
	echo >&2 "Usage: $0 [-n]"
	exit 1
fi

[ -z "$BROWSER" ] && BROWSER=firefox

mpc=`mpc | head -1`
[ -z "$mpc" ] && { echo "$0: no mpc output" >&2; exit 1; }

ddg.sh '!yt '"$mpc"
