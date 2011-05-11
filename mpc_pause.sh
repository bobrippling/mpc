#!/bin/sh

usage(){
	echo "Usage: $0 [-time]" >&2
	exit 1
}

set -e

n=120

if [ $# -eq 1 ]
then
	if echo $1 | grep '^-[0-9]\+$' > /dev/null
	then
		n=`echo $1 | sed 's/^.//'`
	else
		usage
	fi
elif [ $# -ne 0 ]
then usage
fi

mpc_single.sh
mpc single off
sleep $n
mpc play
