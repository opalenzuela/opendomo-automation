#!/bin/sh
#desc: Delete rule condition
#package:odai
#type:local

# Copyright(c) 2011 OpenDomo Services SL. Licensed under GPL v3 or later

RULEPATH="/etc/opendomo/rules"

if test -z "$1"; then
	echo "#WARN No rule condition specified"
	/usr/local/opendomo/editRule.sh
	exit 1
fi

FILE=`echo $1 | cut -f1 -d-`
CONDITION=`echo $@ | sed -e "s/$FILE-//g" -e 's/ /,/g'`

if test -f $RULEPATH/$FILE; then
	sed -i "$CONDITION d" $RULEPATH/$FILE
	echo "#INFO Rule condition removed"
	/usr/local/opendomo/editRule.sh $FILE
else
	echo "#ERR File not found"
	/usr/local/opendomo/editRule.sh 
	echo 2
fi

