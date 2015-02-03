#!/bin/sh
#desc:Delete action
#type:local
#package:odauto

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

ACTPATH="/etc/opendomo/actions"

if test -f "$ACTPATH/$1.action"; then
	rm -fr "$ACTPATH/$1.action"
fi

# Once deleted, back to the main script
/usr/local/opendomo/manageActions.sh
