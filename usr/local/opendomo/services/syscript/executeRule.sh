#!/bin/sh
#desc:Execute rule
#type:local
#package:odauto

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

RULESDIR="/etc/opendomo/rules"

if ! test -z "$1"
then
	RULE="$RULESDIR/$1.rule"
	if test -x "$RULE"
	then
		if $RULE
		then
			echo "# Rule $RULE launched"
		else
			echo "#ERR Rule does not fulfill requirements"
		fi
	else
		echo "#ERR File $RULE not found"
	fi
else
	echo "#ERR missing parameter"
fi
echo
