#!/bin/sh
#desc:Bind to ODControl2 device
#package:odauto

### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

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
test -d /var/www/data || mkdir -p /var/www/data


while test -f $PIDFILE
do
	# ODControl2 syntax (lsc)
	#if wget -q $URL/lsc --http-user=$USER --http-password=$PASS -O $TMPFILE 
	#then
	#	#cutting columns and removing system ports
	#	cut -f1,2,3 -d: $TMPFILE  | grep -v '\$' > $LISTFILE
	#else
	#	# ODControl1.6 syntax (lst) 
	#TODO: this should be moved to another bind
	#	wget -q $URL/lst --http-user=$USER --http-password=$PASS -O $TMPFILE
	#	cut -f2,3,1 -d: $TMPFILE > $LISTFILE
	#fi

	#Repeated query error
	#if grep -q E003 $TMPFILE
	#then
	
	
	# Avoid duplicated call error (E003)
	wget $URL/ver --http-user=$USER --http-password=$PASS -O - > /dev/null
	
	# Making the actual call
	if	wget $URL/lsc --http-user=$USER --http-password=$PASS -O $TMPFILE 
	then
		if grep -q DONE $TMPFILE
		then
			echo "Response with DONE. Continue."
			# Filtering and formatting output, removing system ports ($)
			cut -f1,2,3 -d: $TMPFILE  | grep -v '\$' > $LISTFILE
			
			echo >  /var/www/data/$DEVNAME.odauto.tmp
			
			# LSTFILE contiene el listado correcto
			for line in `cat $LISTFILE | xargs` 
			do
				if test "$line" != "DONE"
				then
					PNAME=`echo $line | cut -f1 -d:`
					PTYPE=`echo $line | cut -f2 -d:  | cut -b1-2`
					PVAL=`echo $line | cut -f3 -d:`
					PTAG=`echo $line | cut -f2 -d:  | cut -b4`
					
					INFOFILE="$CFGDIR/$DEVNAME/$PNAME.info"
					# Only if the port was never configured, generate INFOFILE
					if ! test -f $INFOFILE
					then
						echo "Missing $INFOFILE"
						# Obtain type
						case "$PTYPE" in
							DO|DV|Dv)
								echo "way='out'" > $INFOFILE
								# Only write customport if it does not exist
								if ! test -f $CTRLDIR/$DEVNAME/$PNAME; then
									echo -e "#!/bin/sh \n . $CFGDIR/$DEVNAME.conf  \n wget -q $URL/set+$PNAME+\$1 --http-user=\$USER --http-password=\$PASS -O /dev/null " > $CTRLDIR/$DEVNAME/$PNAME
									chmod +x $CTRLDIR/$DEVNAME/$PNAME  
								fi					
							;;
							DI|AI)
								echo "way='in'" > $INFOFILE
							;;
							*)
								echo "way='disabled'" > $INFOFILE
							;;
						esac
						
						#Obtain tag
						if test "$PTAG" != "_"
						then
							cd /etc/opendomo/tags/
							TAG=`ls $PTAG*`
						else
							TAG=""
						fi
						echo "tag='$TAG'" >> $INFOFILE
						
					fi
					
					# Always, refresh the port value
					echo $PVAL  > $CTRLDIR/$DEVNAME/$PNAME.value
					
					# Finally, generate JSON fragment
					echo "{\"Name\":\"$PNAME\",\"Type\":\"$PTYPE-$PTAG\",\"Tag\":\"$tag\",\"Value\":\"$PVAL\",\"Id\":\"$DEVNAME/$PNAME\"}," >> /var/www/data/$DEVNAME.odauto.tmp
				fi
			done
		else	
			echo "#ERR: The query ended with an error"
			cat $TMPFILE
		fi
	
	else
		echo "#WARN: ODControl not responding. We will keep trying"
	fi
	
	# A very quick replacement of the old file with the new one:
	cat /var/www/data/$DEVNAME.odauto.tmp > /var/www/data/$DEVNAME.odauto
	
	# Cleanup
	rm $TMPFILE $LISTFILE
	sleep $REFRESH
done
