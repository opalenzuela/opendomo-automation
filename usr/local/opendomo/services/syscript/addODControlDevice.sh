#!/bin/sh
#desc:Add ODControl device
#package:odauto
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CFGPATH="/etc/opendomo/control"

# GUI that creates the configuration file
if test -z "$3"; then
	# No parameters
	echo "#> Add ODControl device"
	echo "form:`basename $0`"
	echo "	ipaddress	IP address	text	$1"
	echo "	username	Username	text	$2"
	echo "	password	Password	text	$3"
	echo
else
	URL="$1"
	USER="$2"
	PASS="$3"
	TMPFILE="/var/opendomo/tmp/odcontrolconfig.tmp"
	wget -q $URL/ver --http-user=$USER --http-password=$PASS -O $TMPFILE
	if grep -q DONE $TMPFILE; then
        DEVICENAME=`cut -f1 -d' ' $TMPFILE | head -n1`
        mkdir -p /etc/opendomo/control/$DEVICENAME
        CFGFILE="/etc/opendomo/control/$DEVICENAME.conf"
        echo "URL=$URL" > $CFGFILE
        echo "USER=$USER" >> $CFGFILE
        echo "PASS=$PASS" >> $CFGFILE
		echo "TYPE=ODControl" >> $CFGFILE
	else
        echo "#ERROR"
	fi
	rm $TMPFILE
fi

