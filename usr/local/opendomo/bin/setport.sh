#!/bin/sh
#desc:Set port
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

LOGFILE="/var/opendomo/log/odauto.log"
CTRLPATH="/var/opendomo/control"
PORT="$1"
if ! test -z "$PORT"
then
	if ! test -z "$2"
	then
		echo "`date +%s` $CTRLPATH/$PORT $2" >> $LOGFILE
		$CTRLPATH/$PORT $2
		echo "$2" > $CTRLPATH/$PORT.value
		echo "# Port $PORT set to $2"
		logevent portchange odauto "$PORT $2"
		exit 0
	else
		echo "#ERROR Value not specified"
	fi
else
	echo "#ERROR Port not specified"
fi
exit 1
