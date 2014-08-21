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
	

	
do_background() {
	# 1. Saving PID file
	echo -n >$PIDFILE
	
	# 2. Starting device bindings
	cd $CFGDIR
	for devicecfg in *.conf
	do
		if test "$devicecfg" != "*.conf"
		then
			# Init variables
			TYPE="undefined";
			URL=""
			USER=""
			PASS=""
			DEVNAME=`basename $devicecfg | cut -f1 -d.`
			echo "Processing $DEVNAME ..."
			# Load config file
			. ./$devicecfg
			#echo -n "($DEVNAME)"
			case "$TYPE" in
				odcontrol|odcontrol2)
					/bin/sh /usr/local/opendomo/bin/bind_odcontrol.sh /etc/opendomo/control/$DEVNAME.conf
				;;
				undefined|*)
					logevent odauto error "Unknown device type $TYPE"
			esac
		fi
	done	
	
	# 3. Preparing JSON information
	test -d /var/www/data/ || mkdir -p /var/www/data/
	while test -f $PIDFILE
	do
		echo "Compacting information ..."
		echo -n "{\"ports\":[" > /var/www/data/odauto.json
		cat /var/www/data/*.odauto  >> /var/www/data/odauto.json 2>/dev/null
		echo "0]}" >> /var/www/data/odauto.json
		sleep 1
	done
}
	
do_start () {
	log_action_begin_msg "Starting ODAUTO service"
	mkdir -p $CTRLDIR > /dev/null
	$0 background > /dev/null &
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
		echo "$basename $0 is not running"
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
