#!/bin/sh
#desc:Set all ports
#package:odauto

### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

if test -z "$2";then
	echo "#ERROR: This script need two parameters"
else
	cd /etc/opendomo/control
	for device in *; do
		if test -d ./$device ; then
			cd $device
			for port in *.info; do
				source ./$port 
				if test "$tag" = "$1";
				then
					PNAME=`basename $port | cut -f1 -d.`
					echo "Set /var/opendomo/control/$device/$PNAME $2"
					/var/opendomo/control/$device/$PNAME $2
				fi
			done
			cd ..
		fi
	done
fi
exit 0