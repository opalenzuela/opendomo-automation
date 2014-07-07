#!/bin/sh
#desc:Exit current scene
#type:local
#package:odauto

TMPDIR="/var/opendomo/tmp"
if test -f $TMPDIR/exitscene.tmp
then
	echo "#INFO Exiting previous scene"
	# Execute the recovery script created by setScene
	/bin/sh $TMPDIR/exitscene.tmp
	rm $TMPDIR/exitscene.tmp
	rm $TMPDIR/lastscene.tmp
	# Display the available scenes
	/usr/local/opendomo/setScene.sh
else
	echo "#ERR Information about previous state not found"
	exit 1
fi
