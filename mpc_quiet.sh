#!/bin/sh

if [ $# -ne 0 ]
then
	echo "Usage: $0" >&2
	exit 1
fi

vol=`vol.sh`
for i in `seq $vol -1 0`
do
	vol.sh $i > /dev/null
	sleep .05
done

mpc stop
vol.sh $vol
