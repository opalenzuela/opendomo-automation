#!/bin/sh
#desc:Add rules
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

COMMANDS="updateInstalledPackages.sh:Update installed packages,updateLanguageFiles.sh:Update language files"

if test -d /etc/opendomo/actions; then
	COMMANDS="$COMMANDS,@seq:Actions"
	cd /etc/opendomo/actions
	for i in *; do
		if test "$i" != "*"; then
			desc=`grep '#desc' $i | cut -f2 -d:`
			if test -z "$desc"; then
				desc="$i"
			fi
			COMMANDS="$COMMANDS,$i:$desc"
		fi
	done
fi

echo "#> Add"
echo "form:`basename $0`"
echo "	code	Code	text[a-zA-Z0-9]*"
echo "	name	Name	text"
echo "	action	Action	list[$COMMANDS]"

echo 
