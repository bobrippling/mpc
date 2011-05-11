#!/bin/sh

[      $# -ne 0 ] && echo "$0: ignoring args" >&2
[ -z "$BROWSER" ] && BROWSER=firefox

mpc=`mpc | head -1`
[ -z "$mpc" ] && { echo "$0: no mpc" >&2; exit 1; }

"$BROWSER" 'http://duckduckgo.com/?q=!yt '"$mpc"
