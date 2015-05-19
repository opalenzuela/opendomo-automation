#!/bin/sh
### BEGIN INIT INFO
# Provides:          odauto
# Required-Start:    
# Required-Stop:
# Should-Start:      
# Default-Start:     1 2 3 4 5
# Default-Stop:      0 6
# Short-Description: Automation
# Description:       Automation
#
### END INIT INFO

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

. /lib/lsb/init-functions
PIDFILE="/var/opendomo/run/odauto.pid"
CFGDIR=/etc/opendomo/control
CTRLDIR=/var/opendomo/control
PATH="$PATH:/usr/local/opendomo/bin/"
TMPDIR=/var/opendomo/tmp

do_background() {
	test -f $PIDFILE && exit 1

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
			DEVICE=`basename $devicecfg | cut -f1 -d.`
			test -d $CFGDIR/$DEVICE || mkdir -p $CFGDIR/$DEVICE
			echo "Processing $DEVICE ..."
			# Load config file
			. ./$devicecfg
			#echo -n "($DEVNAME)"
			if test -f /usr/local/opendomo/bindings/$TYPE.sh
			then
				/bin/sh /usr/local/opendomo/bindings/$TYPE.sh /etc/opendomo/control/$DEVICE.conf >/dev/null 2>/dev/null &
			else
				logevent error odauto "Unknown device type $TYPE"
			fi
		fi
	done	
	
	
	test -d /var/www/data/ || mkdir -p /var/www/data/
	touch /var/www/data/null.odauto
	while test -f $PIDFILE
	do
		# 3. Updating rule state
		echo "Processing rules ..."
		for rule in /etc/opendomo/rules/*.rule; do
			if test -f "$rule"; then
				bname=`basename $rule` 
				tmpfile="/var/opendomo/tmp/$bname.laststatus"
				prev=`cat $tmpfile 2>/dev/null`
				desc=`head -n3 $rule | grep desc | cut -f2 -d:`
				action=`tail -n1 $rule | cut -b2-`
				test -z "$desc" && desc="$bname"
				
				if $rule; then
					if test "$prev" != "true"; then
						logevent rulechange rules "Rule [$bname] has changed" $rule
						$action rulechange rules $desc $rule 2>/dev/null
					fi
					echo "true" > $tmpfile
				else
					echo "false" > $tmpfile
				fi
			fi
		done
		
		# 4. Preparing JSON information
		echo "Compacting information ..."
		echo -n "{\"ports\":[" > /var/www/data/odauto.json.tmp
		cat /var/www/data/*.odauto  >> /var/www/data/odauto.json.tmp 2>/dev/null
		echo "0]}" >> /var/www/data/odauto.json.tmp
		#TODO Make sure that the format is valid
		mv /var/www/data/odauto.json.tmp /var/www/data/odauto.json 2>/dev/null
		sleep 1
	done
}
	
do_start () {
	log_action_begin_msg "Starting ODAUTO service"
	if test -f $PIDFILE; then
		echo -n "(already started!)"
	else
		touch /var/www/data/prompts.json 
		rm -fr $TMPDIR/listcontrolportscache.tmp
		
		mkdir -p $CTRLDIR > /dev/null
		cd /usr/local/opendomo/daemons/
		$0 background > /dev/null &
	fi
	log_action_end_msg $?
}

do_stop () {
	log_action_begin_msg "Stoping ODAUTO service"
	
	rm $PIDFILE 2>/dev/null	
	cd $CFGDIR
	for device in *.conf
	do
		source ./$device
		echo -n "($DEVNAME)"
	done	
	echo > /var/www/data/odauto.json
	
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
