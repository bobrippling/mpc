#!/bin/sh

usage(){
	echo "Usage: $0 [-sleeptime] regex" >&2
	exit 1
}

curtrack(){
	mpc | head -1
}

playing(){
	curtrack | grep -Fi -- "$1" > /dev/null
	return $?
}

n=5

if echo "$1" | grep '^-[0-9]\+$' > /dev/null
then
	n=`expr "$1" \* -1`
	shift
fi

if [ $# -eq 0 ]
then
	now=`curtrack`
	while playing "$now"
	do sleep $n
	done
elif [ $# -eq 1 ]
then
	while ! playing "$1"
	do sleep $n
	done
else
	usage
fi
