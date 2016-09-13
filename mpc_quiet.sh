#!/bin/sh

if [ $# -ne 0 ]
then
	echo "Usage: $0" >&2
	exit 1
fi

vol=`vol`
for i in `seq $vol -1 0`
do
	vol $i
	sleep .05
done

mpc --wait stop
vol $vol
