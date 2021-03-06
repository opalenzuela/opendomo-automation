#!/bin/sh
#desc:ODControl2
#package:odauto

### Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

PIDFILE="/var/opendomo/run/odauto.pid"
CFGDIR="/etc/opendomo/control"
CTRLDIR="/var/opendomo/control"

# Special case, if 1st param is "validate", we validate the configuration file sent as 2nd
if test "$1" = "validate" && ! test -z "$2"
then
	CONFIG="$2"
	source $CONFIG
	TMPFILE="/var/opendomo/tmp/$DEVNAME.tmp"
	#TODO Whenever "ver" is adapted to indicate the UID, adapt this query to obtain it
	# and use it as the device internal name instead of the URL/IP
	if	wget $URL/lsc --http-user=$USERNAME --http-password=$PASS -O $TMPFILE 
	then
		if grep DONE $TMPFILE
		then
			echo "#INFO Device found" 
			exit 0
		else
			echo "#ERR: Invalid device"
			exit 2
		fi
	else
		exit 1
	fi
else
	CONFIG="$1"
fi


# Selecting the configuration file
if test -f $CONFIG
then
	echo "Sourcing from $CONFIG"
	source $CONFIG
else
	if test -f /etc/opendomo/control/$CONFIG.conf
	then
		source /etc/opendomo/control/$CONFIG.conf
	else
		echo "#ERROR: Invalid configuration file"
		exit 1
	fi
fi

TMPFILE="/var/opendomo/tmp/$DEVNAME.tmp"
LISTFILE="/var/opendomo/tmp/$DEVNAME.lst"


# Preparations:
test -d $CTRLDIR/$DEVNAME/ || mkdir -p $CTRLDIR/$DEVNAME/
test -d /var/www/data || mkdir -p /var/www/data

# The actual loop 
while test -f $PIDFILE
do
	# Avoid duplicated call error (E003)
	wget -q $URL/ver --http-user=$USERNAME --http-password=$PASS -O - > /dev/null
	
	echo >  /var/www/data/$DEVNAME.odauto.tmp
	
	# Making the actual call
	if	wget -q $URL/lsc --http-user=$USERNAME --http-password=$PASS -O $TMPFILE 
	then
		if grep -q DONE $TMPFILE
		then
			echo "Response with DONE. Continue."
			# Filtering and formatting output, removing system ports ($)
			grep -v '\$' $TMPFILE | sed 's/ /+/g' > $LISTFILE
			
			
			
			# LSTFILE contiene el listado correcto
			for line in `cat $LISTFILE | xargs -L 1` 
			do
				echo " PROCESSING LINE [$line] "
				if test "$line" != "DONE"
				then
					PNAME=`echo $line | cut -f1 -d:`
					PTYPE=`echo $line | cut -f2 -d:  | cut -b1-2`
					PVAL=`echo $line | cut -f3 -d:`
					PTAG=`echo $line | cut -f2 -d:  | cut -b4`
					
					echo "    PNAME=$PNAME PTYPE=$PTYPE PVAL=$PVAL PTAG=$PTAG"
					
					INFOFILE="$CFGDIR/$DEVNAME/$PNAME.info"
					# Only if the port was never configured, generate INFOFILE
					if ! test -f $INFOFILE
					then
						echo "Missing $INFOFILE"
						# Configuration for INPUT / OUTPUT
						case "$PTYPE" in
							DO|DV|Dv|AO|AV)			
							# Saving info
							echo "way='out'" > $INFOFILE

							;;
							DI|AI)
								echo "way='in'" > $INFOFILE
							;;
							*)
								echo "way='disabled'" > $INFOFILE
								echo "status='disabled'" >> $INFOFILE
							;;
						esac
							
						# Special configuration for ANALOG / DIGITAL
						case "$PTYPE" in 
							DO|DV|Dv)
								echo "values='on,off'" >> $INFOFILE
							;;						
							AO|AV|AI)
								MIN=`echo $line | cut -f4 -d: | cut -f1 -d'|'`
								MAX=`echo $line | cut -f4 -d: | cut -f2 -d'|'` 
								echo "min='$MIN'" >> $INFOFILE
								echo "max='$MAX'" >> $INFOFILE							
								echo "values='$MIN-$MAX'" >> $INFOFILE
							;;
						esac
						
						
						# Generic configurations: Obtain tag
						if test "$PTAG" != "_"
						then
							cd /etc/opendomo/tags/
							TAG=`ls $PTAG*`
						else
							TAG=""
						fi
						echo "tag='$TAG'" >> $INFOFILE
						echo "desc='$PNAME'" >> $INFOFILE
					fi
					
					case "$PTYPE" in
						DO|DV|Dv|AO|AV)	
							# Only write customport if it does not exist
							if test -f $CTRLDIR/$DEVNAME/$PNAME; then
								echo "Port $PNAME exists"
							else
								echo "Creating $CTRLDIR/$DEVNAME/$PNAME"
								echo -e "#!/bin/sh \n . $CFGDIR/$DEVNAME.conf  \n" > $CTRLDIR/$DEVNAME/$PNAME
								echo -e "#desc:$PNAME" >> $CTRLDIR/$DEVNAME/$PNAME
								echo -e "if test -z \$1; then \n" >> $CTRLDIR/$DEVNAME/$PNAME
								echo -e "	cat \$0.value \n" >> $CTRLDIR/$DEVNAME/$PNAME
								echo -e "else \n" >> $CTRLDIR/$DEVNAME/$PNAME
								echo -e "	wget -q $URL/set+$PNAME+\$1 --http-user=\$USERNAME --http-password=\$PASS -O /dev/null " >> $CTRLDIR/$DEVNAME/$PNAME
								echo -e "fi\n" >> $CTRLDIR/$DEVNAME/$PNAME
								chmod +x $CTRLDIR/$DEVNAME/$PNAME  
							fi		
						;;
					esac
					
					# These values shall be override in $INFOFILE
					desc=$PNAME
					min=0
					max=100
					status=""
					source $INFOFILE
					
					OLDVAL=`cat $CTRLDIR/$DEVNAME/$PNAME.value`
					# Always, refresh the port value
					echo $PVAL  > $CTRLDIR/$DEVNAME/$PNAME.value
					if test "$PVAL" != "$OLDVAL"; then
						/bin/logevent portchange odauto "$DEVNAME/$PNAME $PVAL"
					fi
					
					# Finally, generate JSON fragment
					if test "$status" != "disabled"
					then
						echo "{\"Name\":\"$desc\",\"Type\":\"$PTYPE\",\"Tag\":\"$tag\",\"Value\":\"$PVAL\",\"Min\":\"$min\",\"Max\":\"$max\",\"Id\":\"$DEVNAME/$PNAME\"}," >> /var/www/data/$DEVNAME.odauto.tmp
					fi
				fi
			done
			logevent "debug" $DEVNAME "Device [$DEVNAME] responded"
		else
			# Every "if" must have an "else"
			echo "#ERR: The query ended with an error"
			logevent "warning" $DEVNAME "Device [$DEVNAME] returned an error"
			cat $TMPFILE
		fi
	
	else
		logevent "warning" $DEVNAME "Device [$DEVNAME] did not respond"
		echo "#WARN: ODControl not responding. Trying later"
	fi
	
	# A very quick replacement of the old file with the new one:
	mv /var/www/data/$DEVNAME.odauto.tmp /var/www/data/$DEVNAME.odauto 2>/dev/null
	
	# Cleanup
	rm -fr $TMPFILE $LISTFILE
	
	# Wait the specified seconds before next polling
	sleep $REFRESH
done
rm -fr $CTRLDIR/$DEVNAME