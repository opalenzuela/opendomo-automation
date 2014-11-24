#!/bin/sh
#desc:Wait
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

PAR="$1"
UNIT=`echo $PAR | sed 's/[0-9]*//g'`
AMOUNT=`echo $PAR | sed 's/[a-z]*//g'`

case "$UNIT" in 
    "s"|"")
		#/bin/sleep $AMOUNT
	;;
	"m")
		let AMOUNT=$AMOUNT*60
	;;
	"h")
		let AMOUNT=$AMOUNT*3600
	;;	
esac
echo "# Waiting [$1] seconds"
/bin/sleep $AMOUNT
