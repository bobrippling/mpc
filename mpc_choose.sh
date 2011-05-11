#!/bin/sh

usage(){
	echo "Usage: $0 ls | [0-9]+" >&2
	echo " ls:     numbered list (suitable for grep)" >&2
	echo " [0-9]+: song choice" >&2
	exit 1
}

list(){
	exec mpc playlist | nl
}

play(){
	exec mpc play $1
}

if [ $# -ne 1 ]
then usage
fi

if [ "$1" = 'ls' ]
then list
elif echo $1 | grep '^[0-9]\+$' > /dev/null
then play $1
else usage
fi
