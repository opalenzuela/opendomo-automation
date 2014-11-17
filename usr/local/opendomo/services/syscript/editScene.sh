#!/bin/sh
#desc:Edit scene
#package:odauto
#type:local

# Copyright(c) 2012 OpenDomo Services SL. Licensed under GPL v3 or later

CFGPATH="/etc/opendomo/scenes"
CTLPATH="/etc/opendomo/control"
TMPFILE="/var/opendomo/tmp/cfgscence.tmp"

if test -z "$1"; then
	echo "#WARN No scene was specified"
	echo
	exit 0

elif ! test -z "$1" && test -f "$CFGPATH/$1"; then
	echo "$1" > $TMPFILE
	CFGFILE="$CFGPATH/`cat $TMPFILE`.conf"

elif ! test -z "$2" && test -f $TMPFILE; then
	CFGFILE=$CFGPATH/`cat $TMPFILE`.conf
	#source $CFGFILE
	PORTS=`grep var/opendomo $CFGFILE| sed -e 's/\/var\/opendomo\/control\///' -e 's/\//_/'`
	for p in $values; do
		oldpname=`echo $p | cut -f1 -d' '`
		oldvalue=`echo $p | cut -f2 -d' '`
		if [ "$1" == "$oldpname" ]; then
			newvalues="$newvalues $oldpname $2"
		else
			newvalues="$newvalues $p"
		fi
	done
	echo "#desc:$desc "	 	 > $CFGFILE
	echo "desc='$desc'"		>> $CFGFILE
	echo "plist='$plist'" 		>> $CFGFILE
	echo "values='$newvalues'" 	>> $CFGFILE
	echo "#INFO Changes saved"

else
	echo "#ERR Scene [$1] not found"
	exit 1

fi

source $CFGFILE
echo "#> Editing scene [$desc]"
echo "form:editScene.sh"
echo "	:	By default, a scene is created with the state that the ports have in the creation moment 	:"
echo "	:	You can modify the individual state of each device in this page	:"
echo "	file	hidden	hidden	$1"
PORTS=`grep var/opendomo $1| sed -e 's/\/var\/opendomo\/control\///' -e 's/\//_/'`
for p in $PORTS; do
	pname=`echo $p | cut -f1 -d' '`
	valselected=`echo $p | cut -f2 -d' '`
	fname=`echo $pname | sed 's/_/\//'`

	if test -f $CTLPATH/$fname.info; then
		source $CTLPATH/$fname.info
	else
		desc=$pname
	fi
	echo	"	$pname	$desc	list[on,off]	$valselected"
done
echo "actions:"
echo "	manageScenes.sh	Back to list"
echo
