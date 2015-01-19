#!/bin/sh
#desc:Delete rule
#type:local
#package:odauto

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

RULESDIR="/etc/opendomo/rules"

if test -z "$1"; then
	echo "#INFO: No rule specified"
	exit 1
fi

for file in "$@"
do
	if test -f "$RULESDIR/$file.rule"; then
		if rm -f "$RULESDIR/$file.rule"; then
			echo "#INFO Rule deleted [$file]"
		else
			echo "#ERR: Cannot delete"
			exit 2
		fi
	fi
done

/usr/local/opendomo/manageRules.sh
