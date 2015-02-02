#!/bin/sh
#desc:ODControl
#package:odauto

### Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later
 
# validate device
if test "$1" == "validate"; then
	source "$2" 

	# Validation command
        if
	wget $URL/ver+ --http-user=$USER --http-password=$PASS -O - &>/dev/null
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
	if wget -q $URL/lst --http-user=$USER --http-password=$PASS -O $TMPFILE
	then
		
		echo "Response with DONE. Continue."
	
		# Filtering and formatting output
		cut -f1,2,3 -d: $TMPFILE   > $LISTFILE
			
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
				fi
					
				# These values shall be override in $INFOFILE
				desc=$PNAME
				min=0
				max=100
				source $INFOFILE
					
				# Always, refresh the port value
				echo $PVAL  > $CTRLDIR/$DEVNAME/$PNAME.value
					
				# Finally, generate JSON fragment
				if test "$status" != "disabled"
				then
					echo "{\"Name\":\"$desc\",\"Type\":\"$PTYPE\",\"Tag\":\"$tag\",\"Value\":\"$PVAL\",\"Min\":\"$min\",\"Max\":\"$max\",\"Id\":\"$DEVNAME/$PNAME\"}," >> /var/www/data/$DEVNAME.odauto.tmp
				fi
			fi
		done
	else
		echo "#WARN: ODControl not responding. We will keep trying"
	fi
	
	# A very quick replacement of the old file with the new one:
	mv /var/www/data/$DEVNAME.odauto.tmp /var/www/data/$DEVNAME.odauto
	
	# Cleanup
	rm -fr $TMPFILE $LISTFILE 
	sleep $REFRESH
done
rm -fr $CTRLDIR/$DEVNAME