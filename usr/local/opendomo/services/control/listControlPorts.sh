#!/bin/sh
#name:List controllers
#desc:List controllers
#package:odcontrol
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CTRLPATH="/var/opendomo/control"
CFGPATH="/etc/opendomo/control"

# All the logic is applied in the JavaScript, client layer
if ! test -z "$2"
then
	if test -x $CTRLPATH/$1
	then
		$CTRLPATH/$1 $2
	else
		echo "#ERROR Port $1 does not exist"
	fi
fi

echo "list:listControlPorts.sh"
echo "	loading	loading	loading"
echo "actions:"
if test -x /usr/local/opendomo/manageTags.sh; then
	echo "	manageTags.sh	Manage tags"
fi
if test -x /usr/local/opendomo/configureControlPorts.sh; then
	echo "	configureControlPorts.sh	Configure control ports"
fi
echo
