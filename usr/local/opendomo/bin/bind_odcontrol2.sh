#!/bin/sh
#desc:ODControl2
#package:odauto

### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later


PIDFILE="/var/opendomo/run/odauto.pid"
TMPFILE="/var/opendomo/tmp/$DEVNAME.tmp"
LISTFILE="/var/opendomo/tmp/$DEVNAME.lst"
CFGDIR="/etc/opendomo/control"
CTRLDIR="/var/opendomo/control"

# Special case, if 1st param is "validate", we validate the configuration file sent as 2nd
if test "$1" = "validate" && ! test -z "$2"
then
	CONFIG="$2"
	source $CONFIG
	#TODO Whenever "ver" is adapted to indicate the UID, adapt this query to obtain it
	# and use it as the device internal name instead of the URL/IP
	if	wget $URL/lsc --http-user=$USER --http-password=$PASS -O $TMPFILE 
	then
		if grep DONE $TMPFILE
		then
			exit 0
		else
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




# Preparations:
test -d $CTRLDIR/$DEVNAME/ || mkdir -p $CTRLDIR/$DEVNAME/
test -d /var/www/data || mkdir -p /var/www/data

# The actual loop 
while test -f $PIDFILE
do
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
						# Configuration for INPUT / OUTPUT
						case "$PTYPE" in
							DO|DV|Dv|AO|AV)
								# Only write customport if it does not exist
								if test -f $CTRLDIR/$DEVNAME/$PNAME; then
									echo "Port $PNAME exists"
								else
									echo "Creating $CTRLDIR/$DEVNAME/$PNAME"
									echo -e "#!/bin/sh \n . $CFGDIR/$DEVNAME.conf  \n wget -q $URL/set+$PNAME+\$1 --http-user=\$USER --http-password=\$PASS -O /dev/null " > $CTRLDIR/$DEVNAME/$PNAME
									chmod +x $CTRLDIR/$DEVNAME/$PNAME  
								fi					
								# Saving info
								echo "way='out'" > $INFOFILE

							;;
							DI|AI)
								echo "way='in'" > $INFOFILE
							;;
							*)
								echo "way='disabled'" > $INFOFILE
							;;
						esac
							
						# Special configuration for ANALOG / DIGITAL
						case "$PTYPE" in 
							AO|AV|AI)
								MIN=`echo $line | cut -f4 -d: | cut -f1 -d'|'`
								MAX=`echo $line | cut -f4 -d: | cut -f2 -d'|'` 
								echo "min='$MIN'" >> $INFOFILE
								echo "max='$MAX'" >> $INFOFILE							
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
					
					# These values shall be override in $INFOFILE
					desc=$PNAME
					min=0
					max=100
					source $INFOFILE
					
					# Always, refresh the port value
					echo $PVAL  > $CTRLDIR/$DEVNAME/$PNAME.value
					
					# Finally, generate JSON fragment
					if test "$way" != "disabled"
					then
						echo "{\"Name\":\"$desc\",\"Type\":\"$PTYPE\",\"Tag\":\"$tag\",\"Value\":\"$PVAL\",\"Min\":\"$min\",\"Max\":\"$max\",\"Id\":\"$DEVNAME/$PNAME\"}," >> /var/www/data/$DEVNAME.odauto.tmp
					fi
				fi
			done
			logevent "notice" $DEVNAME "Device [$DEVNAME] responded"
		else
			# Every "if" must have an "else"
			echo "#ERR: The query ended with an error"
			logevent "error" $DEVNAME "Device [$DEVNAME] returned an error"
			cat $TMPFILE
		fi
	
	else
		logevent "warning" $DEVNAME "Device [$DEVNAME] did not respond"
		echo "#WARN: ODControl not responding. Trying later"
	fi
	
	# A very quick replacement of the old file with the new one:
	cat /var/www/data/$DEVNAME.odauto.tmp > /var/www/data/$DEVNAME.odauto
	
	# Cleanup
	rm $TMPFILE $LISTFILE
	
	# Wait the specified seconds before next polling
	sleep $REFRESH
done
