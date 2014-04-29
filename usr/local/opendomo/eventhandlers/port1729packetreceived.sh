#!/bin/sh
#desc:Process package received in port 1729

# Note that this eventhandler is temporary used by newodhal.sh script, which
# does not follow the proper eventhandler parameter structure, and provides 
# the information by STDIN
if test -z "$3"; then
	echo "Input data:"
	read DATA
else 
	DATA="$3 $4"
fi
SOURCEIP=`echo $DATA | cut -f2 -d[ |  cut -f1 -d]`
/usr/local/opendomo/eventhandlers/autoconfigureODControl.sh odcontroldetected odhal "New device detected" $SOURCEIP