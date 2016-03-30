#!/bin/sh

cleanup(){
	#echo -n
	exit 0
}

usage(){
	echo "Usage: $0 [-t|-b]"
	exit 1
}

bar(){
	val=`expr $1 / 2` # from 0 - 50 (80 cols)
	extra=`expr 50 - $val`
	str='['
	while [ $val -gt 0 ]
	do
		str="$str="
		val=`expr $val - 1`
	done
	while [ $extra -gt 0 ]
	do
		str="$str-"
		extra=`expr $extra - 1`
	done
	printf -- "$str]\r"
}

trap cleanup INT EXIT

mode='bar'
once=0

for arg in $@
do
	if [ "$arg" = '-t' ]
	then mode='text'
	elif [ "$arg" = '-b' ]
	then mode='bar'
	elif [ "$arg" = '-1' ]
	then once=1
	else usage
	fi
done

while :
do
	if ! mpc | grep playing > /dev/null
	then printf '\e[2Knot playing\r'
	else
		fraction="`mpc|grep playing|awk '{print $3}'`"
		left_min=` echo $fraction | sed 's/\([^:]*\):.*/\1/'`
		left_sec=` echo $fraction | sed 's#[^:]:\([^:]*\)/.*#\1#'`
		right_min=`echo $fraction | sed 's#.*/\([^:]*\):.*#\1#'`
		right_sec=`echo $fraction | sed 's#.*/.*:##'`

		left=` expr $left_min  \* 60 + $left_sec`
		right=`expr $right_min \* 60 + $right_sec`

		if [ $right = 0 ]
		then percent=0
		else
			percent="`expr 100 \* $left / $right`"
			if [ "$mode" = 'text' ]
			then
				printf "$percent%%   \\r"
			else
				bar $percent
			fi
		fi
	fi
	sleep 1
	if [ $once -eq 1 ]
	then break
	fi
done
