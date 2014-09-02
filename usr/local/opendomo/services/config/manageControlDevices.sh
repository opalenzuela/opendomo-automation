#!/bin/sh
#desc:Manage control devices
#package:odauto
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CFGPATH="/etc/opendomo/control"
CTRLPATH="/var/opendomo/control"
PS=""
PORTS=""

mkdir -p $CFGPATH


# Available control devices
echo "#> Available"
echo "list:addControlDevice.sh	selectable"

cd $CFGPATH
EXISTS=0
for i in *.conf; do
	if test "$i" != "*.conf" && test -f $i
	then
		source ./$i
		echo "	-$DEVNAME	$DEVNAME	device $TYPE"
		EXISTS=1
	fi
done
		
if test "$EXISTS" = "0" ; then
	echo "# There are no control devices. Please, go to Add."
fi

echo "actions:"
echo "	addControlDevice.sh	Add"
echo "	delControlDevice.sh	Delete"
echo "	configureControlPorts.sh	Configure control devices"
echo
