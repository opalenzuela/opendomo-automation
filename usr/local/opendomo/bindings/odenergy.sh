#!/bin/sh
#desc:ODEnergy
#package:odauto

### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

# validate device
if test "$1" == "validate"; then
	source "$2"

	# Validation command
	if wget $URL/data.xml --http-user=$USERNAME --http-password=$PASS -O - 
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
	echo >  /var/www/data/$DEVNAME.odauto.tmp

	# Making the actual call
	if wget -q $URL/data.xml --http-user=$USERNAME --http-password=$PASS -O $TMPFILE
	then
		# LSTFILE contiene el listado correcto
		for PNAME in voltage_L1 voltage_L2 voltage_L3 current_L1 current_L2 current_L3
		do
			INFOFILE=$CFGDIR/$DEVNAME/$PNAME.info
			if ! test -f "$INFOFILE"; then
				echo "way='in'" > $INFOFILE
				echo "tag='power'" >> $INFOFILE
				echo "desc='$PNAME'" >> $INFOFILE
				case $PNAME in
					voltage_L1|voltage_L2|voltage_L3)
						echo "min='0'" >> $INFOFILE
						echo "max='400'" >> $INFOFILE
						echo "values='100-400'" >> $INFOFILE
					;;
					current_L1|current_L2|current_L3)
						echo "min='0'" >> $INFOFILE
						echo "max='100000'" >> $INFOFILE
						echo "values='0-100000'" >> $INFOFILE
					;;
				esac
			else
				source $INFOFILE
			fi
			PORTFILE=$CTRLDIR/$DEVNAME/$PNAME
			if ! test -f "$PORTFILE"; then
				echo "Creating $PORTFILE"
				echo -e "#!/bin/sh \n . $CFGDIR/$DEVNAME.conf  \n" > $PORTFILE
				echo -e "#desc:$PNAME" >> $PORTFILE
				echo -e "if test -z \$1; then \n" >> $PORTFILE
				echo -e "	cat \$0.value \n" >> $PORTFILE
				echo -e "else \n" >> $PORTFILE
				echo -e "	exit 1 \n " >> $PORTFILE
				echo -e "fi\n" >> $PORTFILE
				chmod +x $PORTFILE  
			fi
		
			PVAL=`grep $PNAME $TMPFILE | tail -n1 | cut -f2 -d'>' | cut -f1 -d'<' `
			OLDVAL=`cat $CTRLDIR/$DEVNAME/$PNAME.value`
			# Always, refresh the port value
			echo $PVAL  > $CTRLDIR/$DEVNAME/$PNAME.value
			if test "$PVAL" != "$OLDVAL"; then
				/bin/logevent odauto portchange "$DEVNAME/$PNAME $PVAL"
			fi
				
			# Finally, generate JSON fragment
			if test "$status" != "disabled"
			then
				echo "{\"Name\":\"$desc\",\"Type\":\"AI\",\"Tag\":\"power\",\"Value\":\"$PVAL\",\"Min\":\"$min\",\"Max\":\"$max\",\"Id\":\"$DEVNAME/$PNAME\"}," >> /var/www/data/$DEVNAME.odauto.tmp
			fi
		done
	else
		echo "#WARN: Device [$DEVNAME] not responding. We will keep trying"
		/bin/logevent odauto warning "Device [$DEVNAME] not responding. We will keep trying"
	fi
	
	# A very quick replacement of the old file with the new one:
	mv /var/www/data/$DEVNAME.odauto.tmp /var/www/data/$DEVNAME.odauto
	
	# Cleanup
	rm -fr $TMPFILE $LISTFILE 
	sleep $REFRESH
done
rm -fr $CTRLDIR/$DEVNAME