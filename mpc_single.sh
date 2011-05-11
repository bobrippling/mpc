#!/bin/sh

usage(){
  echo "Usage: $0 [off]"
  exit 1
}

off(){
  mpc -q repeat on && mpc -q single off
  exit
}

set -e

if [ $# -eq 1 ]
then
  if [ "$1" = "reset" ]
  then
    while mpc | grep -F '[playing]' > /dev/null
    do sleep 1
    done

    off
  elif [ "$1" = "off" ]
  then off
  else
    usage
  fi
elif [ $# -ne 0 ]
then
  usage
fi

mpc -q repeat off && mpc -q single on
