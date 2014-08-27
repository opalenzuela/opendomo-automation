#!/bin/sh
#desc:Add Control device
#package:odauto
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CFGPATH="/etc/opendomo/control"

#TODO: Generate dynamically from the installed bindings
DEVICETYPELIST="odcontrol:ODControl,odcontrol2:ODControl2"

# GUI that creates the configuration file
if test -z "$3"; then
	if test -z "$1"
	then
		# No parameters
		TYPE="odcontrol2"
	else
		# ONE parameter (the device name)
		if test -f /etc/opendomo/control/$1.conf
		then
			source /etc/opendomo/control/$1.conf
		else
			echo "#ERR: The device cannot be edited"
			exit 1
		fi
	fi
	echo "#> Add Control device"
	echo "form:`basename $0`"
	echo "	ipaddress	URL	text	$URL"
	echo "	username	Username	text	$USER"
	echo "	password	Password	text	$PASS"
	echo "	type	Type	list[$DEVICETYPELIST]	$TYPE"
	echo "	refresh	Refresh	text	$REFRESH"
	echo
else
	URL="$1"
	USER="$2"
	PASS="$3"
	TYPE="$4"
	REFRESH="$5"
	TMPFILE="/var/opendomo/tmp/controlconfig.tmp"
	
	# For certain devices, we need additional information
	case "$TYPE" in
		odcontrol|odcontrol2)
			if wget -q $URL/ver --http-user=$USER --http-password=$PASS -O $TMPFILE
			then
				if grep -q DONE $TMPFILE
				then
					DEVICENAME=`cut -f1 -d' ' $TMPFILE | head -n1`
				else
					echo "#ERR: Invalid response from device"
					exit 1
				fi	
			else
				echo "#ERR: The device is not available at this moment or credentials were wrong"
				exit 2
			fi
			rm $TMPFILE
		;;
		*)
			DEVICENAME=`basename $URL`
			echo "#WARN: Unknown device type [$TYPE]"
		;;
	esac
	
	# Saving configuration
	mkdir -p /etc/opendomo/control/$DEVICENAME
	CFGFILE="/etc/opendomo/control/$DEVICENAME.conf"
	echo "URL=$URL" > $CFGFILE
	echo "USER=$USER" >> $CFGFILE
	echo "PASS=$PASS" >> $CFGFILE
	echo "TYPE=$TYPE" >> $CFGFILE
	echo "REFRESH=$REFRESH" >> $CFGFILE
	echo "DEVNAME=$DEVICENAME" >> $CFGFILE
	echo "#INFO The device was created and it will be available soon"			
	/usr/local/opendomo/daemons/odauto.sh restart > /dev/null
	/usr/local/opendomo/manageControlDevices.sh
	echo
fi

