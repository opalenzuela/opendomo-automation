#!/bin/sh
#desc:Wait
#package:odauto
if ! test -z "$1"; then
	echo "# Waiting [$1] seconds"
	/bin/sleep $1
fi
