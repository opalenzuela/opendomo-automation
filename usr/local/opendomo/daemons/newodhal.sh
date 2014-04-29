#!/bin/sh
### BEGIN INIT INFO
# Provides:          newodhal
# Required-Start:    
# Required-Stop:
# Should-Start:      
# Default-Start:     1 2 3 4 5
# Default-Stop:      0 6
# Short-Description: Opendomo new odhal
# Description:       Hardware Abstraction Layer
#
### END INIT INFO
### Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later


. /lib/lsb/init-functions
PIDFILE="/var/opendomo/run/newodhal.pid"

do_start () {
	log_action_begin_msg "Starting new ODHAL service"
	echo -n >$PIDFILE
	/usr/local/opendomo/daemons/odhal stop
	nc -ulvn -p1729 | /usr/local/opendomo/eventhandlers/port1729packetreceived.sh &
	log_action_end_msg $?
}

do_stop () {
	log_action_begin_msg "Stoping new ODHAL service"
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
