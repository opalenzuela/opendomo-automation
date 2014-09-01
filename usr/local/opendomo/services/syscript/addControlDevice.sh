#!/bin/sh
#desc:Add Control device
#package:odauto
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CFGPATH="/etc/opendomo/control"

#TODO: Generate dynamically from the installed bindings
cd /usr/local/opendomo/bin/
for binding in bind_*.sh
do
	BID=`echo $binding | cut -f2 -d_ | cut -f1 -d.`
	BDESC=`grep #desc $binding | cut -f2 -d:`
	DEVICETYPELIST="$DEVICETYPELIST,$BID:$BDESC"
done

#DEVICETYPELIST="odcontrol:ODControl,odcontrol2:ODControl2"

# If we are passing all 5 parameters, 
if ! test -z "$5"; then
	URL="$1"
	USER="$2"
	PASS="$3"
	TYPE="$4"
	REFRESH="$5"
	TMPFILE="/var/opendomo/tmp/controlconfig.tmp"
	
	# Saving configuration
	DEVICENAME=`basename $URL`
	mkdir -p /etc/opendomo/control/$DEVICENAME
	CFGFILE="/etc/opendomo/control/$DEVICENAME.conf"
	echo "URL=$URL" > $CFGFILE
	echo "USER=$USER" >> $CFGFILE
	echo "PASS=$PASS" >> $CFGFILE
	echo "TYPE=$TYPE" >> $CFGFILE
	echo "REFRESH=$REFRESH" >> $CFGFILE
	echo "DEVNAME=$DEVICENAME" >> $CFGFILE
	
	if /usr/local/opendomo/bin/bind_$TYPE.sh validate $CFGFILE
	then
		echo "#INFO The device was created and it will be available soon"			
		/usr/local/opendomo/daemons/odauto.sh restart > /dev/null
		/usr/local/opendomo/manageControlDevices.sh
	else
		echo "#ERR: Cannot connect to the specified device"	
		source $CFGFILE
		# Delete the file and directory
		rm $CFGFILE
		rm -fr /etc/opendomo/control/$DEVICENAME
	fi

	echo
else
	if test -z "$1"
	then
		# No parameters at all
		TYPE="odcontrol2"
		REFRESH=5
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

fi


# Always display the form: empty to create a new one or full to modify
echo "#> Add Control device"
echo "form:`basename $0`"
echo "	ipaddress	URL	text	$URL"
echo "	username	Username	text	$USER"
echo "	password	Password	text	$PASS"
echo "	type	Type	list[$DEVICETYPELIST]	$TYPE"
echo "	refresh	Refresh	text	$REFRESH"
echo
