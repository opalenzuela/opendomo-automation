#!/bin/sh
#name:List controllers
#desc:List controllers
#package:odauto
#group:users
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
		/usr/local/opendomo/bin/setport.sh $1 $2

	else
		echo "#ERR: Port [$1] does not exist"
	fi
fi

cd $CFGPATH
DEVICES=`ls|wc -l`

echo "#> Control ports"
echo "form:listControlPorts.sh"
if /usr/local/opendomo/daemons/odauto.sh status >/dev/null
then
	cd /var/opendomo/control
	for device in *; do 
		cd $device
		for port in *; do
			if test -f /etc/opendomo/control/$device/$port.info; then
				values=""
				way="disabled"
				source /etc/opendomo/control/$device/$port.info
				if test "$way" = "out"; then
					if echo "$values" | grep -q "," ; then
						echo "	$device-$port	$desc	list[$values] switch DO $tag"
					else
						echo "	$device-$port	$desc	range $tag AO"
					fi
				fi
				if test "$way" = "in"; then
					if echo "$values" | grep -q "," ; then
						echo "	$device-$port	$desc	readonly $tag DI	"
					else
						echo "	$device-$port	$desc	readonly $tag AI	"
					fi
				fi				
			fi
		done
		cd ..
	done
	echo "actions:"
	if test -z "$DEVICES"; then
		if test -x /usr/local/opendomo/addControlDevice.sh; then
			echo "	addControlDevice.sh	Add control device"
		fi
	else
		if test -x /usr/local/opendomo/manageTags.sh; then
			echo "	manageTags.sh	Manage tags"
		fi
		if test -x /usr/local/opendomo/configureControlPorts.sh; then
			echo "	configureControlPorts.sh	Configure control ports"
		fi
	fi
else
	echo "#WARN Service is not active"
	echo "actions:"
	echo "	setSystemState.sh	Manage services"
fi
echo
