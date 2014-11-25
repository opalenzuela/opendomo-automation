#!/bin/sh
#desc:Delete action
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

ACTPATH="/etc/opendomo/actions"

if test -f "$ACTPATH/$1"; then
	rm -fr "$ACTPATH/$1"
fi

# Once deleted, back to the main script
/usr/local/opendomo/manageActions.sh
