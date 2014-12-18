#!/bin/sh
#desc:Manage control devices
#package:odauto
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CFGPATH="/etc/opendomo/control"
CTRLPATH="/var/opendomo/control"
DETECTEDPATH="/var/opendomo/tmp/detected"
PS=""
PORTS=""

mkdir -p $CFGPATH

# If one parameter is passed, we configure it
if ! test -z "$1"; then
	if test -f $DETECTEDPATH/$1; then
		source $DETECTEDPATH/$1
		mv $DETECTEDPATH/$1 $CFGPATH/
		addControlDevice.sh $DEVNAME
		exit 0
	fi
fi


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
echo "	configureControlPorts.sh	Configure control ports"
echo

if test -d $DETECTEDPATH; then
	cd $DETECTEDPATH
	echo "#> Detected"
	echo "list:manageControlDevices.sh	detailed"	
	for i in *.conf; do
		if test -f $i; then
			DEVNAME="$i"
			URL=""
			TYPE="unknown"
			source $i
			echo "	-$i	$DEVNAME	$TYPE	$URL"
		fi
	done
fi
echo