#!/bin/sh
#desc:Add Control device
#package:odauto
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CFGPATH="/etc/opendomo/control"

# GUI that creates the configuration file
if test -z "$3"; then
	# No parameters
	echo "#> Add Control device"
	echo "form:`basename $0`"
	echo "	ipaddress	URL	text	$1"
	echo "	username	Username	text	$2"
	echo "	password	Password	text	$3"
	echo "	type	Type	list[ODControl,ODControl2]	ODControl2"
	echo
else
	URL="$1"
	USER="$2"
	PASS="$3"
	TYPE="$4"
	TMPFILE="/var/opendomo/tmp/controlconfig.tmp"
	
	case "$TYPE" in
		ODControl|ODControl2)
			if wget -q $URL/ver --http-user=$USER --http-password=$PASS -O $TMPFILE
			then
				if grep -q DONE $TMPFILE
				then
					DEVICENAME=`cut -f1 -d' ' $TMPFILE | head -n1`
					mkdir -p /etc/opendomo/control/$DEVICENAME
					CFGFILE="/etc/opendomo/control/$DEVICENAME.conf"
					echo "URL=$URL" > $CFGFILE
					echo "USER=$USER" >> $CFGFILE
					echo "PASS=$PASS" >> $CFGFILE
					echo "TYPE=ODControl2" >> $CFGFILE
					echo "#INFO The device was created and it will be available after the service is restarted"
				else
					echo "#ERR: Invalid response from device"
				fi	
			else
				echo "#ERR: The device is not available at this moment or credentials were wrong"
			fi
			rm $TMPFILE
		;;
		*)
			echo "#ERR: Unknown device type [$TYPE]"
			exit 1
		;;
	esac
	echo
fi

