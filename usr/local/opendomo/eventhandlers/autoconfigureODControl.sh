#!/bin/sh
if test -z "$4"; then
	/bin/logevent
	exit 1
fi
TMPFILE="/var/opendomo/tmp/listports-$4.tmp"
URL="http://$4/lsc"
wget $URL -q --http-user=user --http-password=opendomo -O - | cut -f1-3 -d: > $TMPFILE

