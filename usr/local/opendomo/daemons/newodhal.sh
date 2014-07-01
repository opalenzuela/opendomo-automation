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

do_start () {
	log_action_begin_msg "Starting ODAUTO service"
	echo -n >$PIDFILE
	CFGDIR=/etc/opendomo/control
	CTRLDIR=/var/opendomo/control
	while true
	do
		cd $CFGDIR
		for device in *.conf
		do
			. ./$device
			devname=`basename $device | cut -f1 -d.`
			TMPFILE=/var/opendomo/tmp/$device.tmp
			LISTFILE=/var/opendomo/tmp/$device.lst
			if wget -q $URL/lsc --http-user=$USER --http-password=$PASS -O $TMPFILE 
			then
				cut -f1,3 -d: $TMPFILE > $LISTFILE
			else
				wget -q $URL/lst --http-user=$USER --http-password=$PASS -O $TMPFILE
				cut -f2,3 -d: $TMPFILE > $LISTFILE
			fi
			if grep DONE $TMPFILE
			then
				mkdir -p $CTRLDIR/$devname/
				# LSTFILE contiene el listado correcto
				for line in `cat $LISTFILE | xargs` ; do
					PNAME=`echo $line | cut -f1 -d:`
					PVAL=`echo $line | cut -f2 -d:`
					# Only edit if it does not exist
					if ! test -f $CTRLDIR/$devname/$PNAME; then
						echo "/usr/local/opendomo/portHandler.sh $device $PNAME \$1" > $CTRLDIR/$devname/$PNAME
						chmod +x $CTRLDIR/$devname/$PNAME  
					fi
					echo $PVAL  > $CTRLDIR/$devname/$PNAME.value
				done
			fi
			# limpieza
			rm $TMPFILE $LISTFILE
		done
		sleep 10
	done
	log_action_end_msg $?
}

do_stop () {
	log_action_begin_msg "Stoping ODAUTO service"
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
  start|"")
	do_start
        ;;
  restart|reload|force-reload)
	do_start
	do_stop
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
        echo "Usage: newodhal [start|stop|restart|status]" >&2
        exit 3
        ;;
esac
