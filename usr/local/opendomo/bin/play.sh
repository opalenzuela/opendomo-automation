#!/bin/sh
#desc:Play a sound
#package:odauto

if test -x /usr/bin/aplay; then
	if test -f /usr/share/sounds/$1; then
		echo "# Playing [$1]"
		/usr/bin/aplay -q /usr/share/sounds/$1 > /dev/null
	fi
fi
