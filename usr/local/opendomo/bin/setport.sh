#!/bin/sh
#desc:Set port
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CTRLPATH="/var/opendomo/control"
PORT="$1"
if ! test -z "$PORT"
then
	if ! test -z "$2"
	then
		$CTRLPATH/$PORT $2
		echo "$2" > $CTRLPATH/$PORT.value
	else
		echo "#ERROR Value not specified"
	fi
else
	echo "#ERROR Port not specified"
fi
