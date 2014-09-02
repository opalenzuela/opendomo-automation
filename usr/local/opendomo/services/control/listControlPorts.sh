#!/bin/sh
#name:List controllers
#desc:List controllers
#package:odauto
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CTRLPATH="/var/opendomo/control"
CFGPATH="/etc/opendomo/control"
LOGPATH="/var/opendomo/log"

# All the logic is applied in the JavaScript, client layer
if ! test -z "$2"
then
	if test -x $CTRLPATH/$1
	then
		echo "# Setting port $1 to $2"
		$CTRLPATH/$1 $2
		echo "$2" > $CTRLPATH/$1.value
		echo "`date +%s` $CTRLPATH/$1 $2" >> $LOGPATH/actions.log
	else
		echo "#ERR: Port [$1] does not exist"
	fi
fi

echo "#> Control ports"
echo "form:listControlPorts.sh"
if /usr/local/opendomo/daemons/odauto.sh status >/dev/null
then
	#Note that in this version, the population of the ports will be entirely JavaScript
	#Hence, no server-side processing is needed here.
	echo "	loading	loading	loading"
	echo "actions:"
	if test -x /usr/local/opendomo/manageTags.sh; then
		echo "	manageTags.sh	Manage tags"
	fi
	if test -x /usr/local/opendomo/configureControlPorts.sh; then
		echo "	configureControlPorts.sh	Configure control ports"
	fi
else
	echo "#WARN Service is not active"
	echo "actions:"
	echo "	setSystemState.sh	Manage services"
fi
echo
