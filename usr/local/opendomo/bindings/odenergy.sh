#!/bin/sh
#desc:ODEnergy
#package:odauto

### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

# validate device
if test "$1" == "validate"; then
	source "$2"

	# Validation command
	if wget -q $URL/data.xml --http-user=$USER --http-password=$PASS -O - &>/dev/null
	then
		exit 0
	else
		exit 1
	fi
fi

if test -f $1
then
	source $1
else
	if test -f /etc/opendomo/control/$1.conf
	then
		source /etc/opendomo/control/$1.conf
	else
		echo "#ERROR: Invalid configuration file"
		exit 1
	fi
fi


PIDFILE="/var/opendomo/run/odauto.pid"
TMPFILE=/var/opendomo/tmp/$DEVNAME.tmp
LISTFILE=/var/opendomo/tmp/$DEVNAME.lst
CFGDIR=/etc/opendomo/control
CTRLDIR=/var/opendomo/control

# Preparations:
test -d $CTRLDIR/$DEVNAME/ || mkdir -p $CTRLDIR/$DEVNAME/
test -d $CFGDIR/$DEVNAME/ || mkdir -p $CFGDIR/$DEVNAME/
test -d /var/www/data || mkdir -p /var/www/data


while test -f $PIDFILE
do
	# Making the actual call
	if wget -q $URL/data.xml --http-user=$USER --http-password=$PASS -O $TMPFILE
	then
		echo >  /var/www/data/$DEVNAME.odauto.tmp
			
		# LSTFILE contiene el listado correcto
		for param in voltage_L1 voltage_L2 voltage_L3 current_L1 current_L2 current_L3
		do
			grep param $TMPFILE | tail -n1 | cut -f2 -d'>' | cut -f1 -d'<' > $CTRLDIR/$DEVNAME/$PNAME.value
			PVAL=`cat $CTRLDIR/$DEVNAME/$PNAME.value`
			PNAME=$param
			PTYPE="AI"
			PVAL=`echo $line | cut -f3 -d:`
			PTAG="energy"

				
			# Always, refresh the port value
			#echo $PVAL  > $CTRLDIR/$DEVNAME/$PNAME.value
				
			# Finally, generate JSON fragment
			if test "$status" != "disabled"
			then
				echo "{\"Name\":\"$desc\",\"Type\":\"$PTYPE\",\"Tag\":\"$tag\",\"Value\":\"$PVAL\",\"Min\":\"$min\",\"Max\":\"$max\",\"Id\":\"$DEVNAME/$PNAME\"}," >> /var/www/data/$DEVNAME.odauto.tmp
			fi
		done
	else
		echo "#WARN: Device $DEVNAME not responding. We will keep trying"
	fi
	
	# A very quick replacement of the old file with the new one:
	mv /var/www/data/$DEVNAME.odauto.tmp /var/www/data/$DEVNAME.odauto
	
	# Cleanup
	rm -fr $TMPFILE $LISTFILE 
	sleep $REFRESH
done
