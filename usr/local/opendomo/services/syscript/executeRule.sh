#!/bin/sh
#desc:Execute rule
#type:local
#package:odauto

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

RULESDIR="/etc/opendomo/rules"

if test -z "$1"; then
	if test -x "$RULESDIR/$1.rule"; then
		if $RULESDIR/$1.rule; then
			echo "# Rule launched"
		else
			echo "#ERR Rule does not fulfill requirements"
		fi
	fi
fi
echo
