#!/bin/sh
#desc:Bind to ODControl device
#package:odauto

### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

URL=$1
USER=$2
PASS=$3
DEVNAME=$4
TMPFILE=/var/opendomo/tmp/$DEVNAME.tmp
LISTFILE=/var/opendomo/tmp/$DEVNAME.lst
if wget -q $URL/lsc --http-user=$USER --http-password=$PASS -O $TMPFILE 
then
	cut -f1,2,3 -d: $TMPFILE > $LISTFILE
else
	wget -q $URL/lst --http-user=$USER --http-password=$PASS -O $TMPFILE
	cut -f2,3,1 -d: $TMPFILE > $LISTFILE
fi
if grep -q DONE $TMPFILE
then
	mkdir -p $CTRLDIR/$DEVNAME/
	rm /var/www/data/$DEVNAME.odauto
	
	# LSTFILE contiene el listado correcto
	for line in `grep -v '\$' $LISTFILE | xargs` 
	do
		if test "$line" != "DONE"
		then
			PNAME=`echo $line | cut -f1 -d:`
			PTYPE=`echo $line | cut -f2 -d:`
			PVAL=`echo $line | cut -f3 -d:`

			if echo $PTYPE | grep -qE "DO|DV|Dv"
			then
				echo "way='out'" > $CFGDIR/$DEVNAME/$PNAME.info
				# Only edit if it does not exist
				if ! test -f $CTRLDIR/$DEVNAME/$PNAME; then
					echo -e "#!/bin/sh \n . $CFGDIR/$DEVNAME.conf  \n wget -q http://$URL/set+$PNAME+\$1 --http-user=\$USER --http-password=\$PASS -O /dev/null " > $CTRLDIR/$DEVNAME/$PNAME
					chmod +x $CTRLDIR/$DEVNAME/$PNAME  
				fi					
			else
				echo "way='in'" > $CFGDIR/$DEVNAME/$PNAME.info
			fi
			echo $PVAL  > $CTRLDIR/$DEVNAME/$PNAME.value
			
			echo "{\"Name\":\"$PNAME\",\"Type\":\"$PTYPE\",\"Value\":\"$PVAL\",\"Id\":\"$DEVNAME/$PNAME\"}," >> /var/www/data/$DEVNAME.odauto
		fi
	done
fi
# limpieza
rm $TMPFILE $LISTFILE	
