#!/bin/sh
### BEGIN INIT INFO
# Provides:          odauto
# Required-Start:    
# Required-Stop:
# Should-Start:      
# Default-Start:     1 2 3 4 5
# Default-Stop:      0 6
# Short-Description: Automation for OpenDomoOS
# Description:       Automation for OpenDomoOS
#
### END INIT INFO
### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

. /lib/lsb/init-functions
PIDFILE="/var/opendomo/run/odauto.pid"
CFGDIR=/etc/opendomo/control
CTRLDIR=/var/opendomo/control
	
# If the device is an ODControl 
process_odcontrol() {
	URL=$1
	USER=$2
	PASS=$3
	DEVNAME=$4
	TMPFILE=/var/opendomo/tmp/$DEVNAME.tmp
	LISTFILE=/var/opendomo/tmp/$DEVNAME.lst
	if wget -q $URL/lsc --http-user=$USER --http-password=$PASS -O $TMPFILE 
	then
		cut -f1,3 -d: $TMPFILE > $LISTFILE
	else
		wget -q $URL/lst --http-user=$USER --http-password=$PASS -O $TMPFILE
		cut -f2,3 -d: $TMPFILE > $LISTFILE
	fi
	if grep -q DONE $TMPFILE
	then
		mkdir -p $CTRLDIR/$DEVNAME/
		rm /var/www/data/$DEVNAME.odauto
		
		# LSTFILE contiene el listado correcto
		for line in `cat $LISTFILE | xargs` 
		do
			if test "$line" != "DONE"
			then
				PNAME=`echo $line | cut -f1 -d:`
				PVAL=`echo $line | cut -f2 -d:`
				# Only edit if it does not exist
				if ! test -f $CTRLDIR/$DEVNAME/$PNAME; then
					echo "#!/bin/sh 
	. $CFGDIR/$device 
	wget -q http://$URL/set+$PNAME+\$1 --http-user=\$USER --http-password=\$PASS -O /dev/null
	" > $CTRLDIR/$DEVNAME/$PNAME
					chmod +x $CTRLDIR/$DEVNAME/$PNAME  
				fi
				echo "" > $CFGDIR/$DEVNAME/$PNAME.info
				echo $PVAL  > $CTRLDIR/$DEVNAME/$PNAME.value
				
				echo -n "{\"Name\":\"$PNAME\",\"Value\":\"$PVAL\",\"Id\":\"$DEVNAME-$PNAME\"}," >> /var/www/data/$DEVNAME.odauto
			fi
		done
	fi
	# limpieza
	rm $TMPFILE $LISTFILE	
}
	
do_background() {
	echo -n >$PIDFILE
	while test -f $PIDFILE
	do
		cd $CFGDIR
		for devicecfg in *.conf
		do
			# Init variables
			TYPE="undefined";
			URL=""
			USER=""
			PASS=""
			DEVNAME=`basename $devicecfg | cut -f1 -d.`
			# Load config file
			. ./$devicecfg
			#echo -n "($DEVNAME)"
			case "$TYPE" in
				ODControl|ODControl2)
					logevent odauto debug "calling with $URL $USER $PASS $DEVNAME"
					process_odcontrol "$URL" "$USER" "$PASS" "$DEVNAME"
				;;
				undefined|*)
					logevent odauto error "Unknown device type $TYPE"
			esac
		done
		sleep 10
		echo -n "[" > /var/www/data/odauto.json
		cat /var/www/data/*.odauto  >> /var/www/data/odauto.json
		echo "]" >> /var/www/data/odauto.json
		# ln -s /var/www/data/odauto.json /var/www/data/odauto.txt
	done
}
	
do_start () {
	log_action_begin_msg "Starting ODAUTO service"
	$0 background &
	log_action_end_msg $?
}

do_stop () {
	log_action_begin_msg "Stoping ODAUTO service"
	cd $CFGDIR
	for device in *.conf
		do
			DEVNAME=`basename $device | cut -f1 -d.`
			echo -n "($DEVNAME)"
			rm -fr $CTRLDIR/$DEVNAME
		done	
	
	rm $PIDFILE 2>/dev/null
	log_action_end_msg $?
}

do_status () {
	if test -f $PIDFILE; then
		echo "$basename $0 is running"
		exit 0
	else
		eche "$basename $0 is not running"
		exit 1
	fi
}

case "$1" in
	background)
		do_background
		;;
	start)
		do_start
		;;
	restart|reload|force-reload)
		do_stop
		do_start
		exit 3
		;;
	stop)
		do_stop
		exit 3
	;;
	status)
		do_status
		exit $?
		;;
	*)
		echo "Usage: $0 [start|stop|restart|status]" >&2
		exit 3
		;;
esac
