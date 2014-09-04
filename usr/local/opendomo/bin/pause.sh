#!/bin/sh
#desc:Pause
#package:odauto

### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

if test -z "$2"; then
	case "$2" in
		seconds|sec|s)
			sleep $1
		;;
		minutes|min|m)
			let m=$i*60
			sleep $m
		;;
		hours|hrs|h)
			let m=$i*60*60
			sleep $m
		;;		

else
	if test -z "$1"; then
		echo "#ERROR: Missing parameters"
		exit 0
	else
		sleep $1
	fi
fi
