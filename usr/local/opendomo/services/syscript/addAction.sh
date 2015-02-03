#!/bin/sh
#desc:Add action
#type:local
#package:odauto

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

if test -z "$1"
then
	CODE="act`date +%s`"
else
	CODE="$1"
fi

SEQPATH="/etc/opendomo/actions"
if ! test -d $SEQPATH; then
	mkdir -p $SEQPATH 2>/dev/null
fi

echo "form:manageActions.sh"
echo "	code	Code	hidden	$CODE"
echo "	desc	Description	text	New action"
echo
