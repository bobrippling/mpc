#!/bin/sh

if [ $# -ne 0 ]
then
	echo "Usage: $0" >&2
	exit 1
fi

fin(){
	mpc single off > /dev/null
}

trap fin EXIT

{
	mpc single on
	mpc repeat off
} > /dev/null
mpc_wait.sh
