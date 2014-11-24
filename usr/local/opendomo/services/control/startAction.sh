#!/bin/sh
#desc:Start action
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

SEQPATH="/etc/opendomo/actions"
if ! test -d $SEQPATH; then
	mkdir -p $SEQPATH 2>/dev/null
fi


# No parameter. Listing actions
if test -z "$1"; then
	echo "#> Available actions"
	echo "list:`basename $0`	simple"
	EXIST=0
	if !  test -d $SEQPATH; then
		mkdir $SEQPATH
	fi
	cd $SEQPATH 
	for i in *.*; do
		if test -x $i; then
			desc=`grep '#desc' $i | cut -f2 -d:` 2>/dev/null
			TYPE="sequence"
			if test -z "$desc"; then
				desc=$i
			fi
			# Detect if the sequence is active
			if test -f /var/opendomo/run/$BNAME.pid
			then
				TYPE="$TYPE active"
			fi				
			echo "	-$i	$desc	$TYPE"
			EXIST=1
		fi
	done
	if test "$EXIST" = "0" ; then
		if test -x /usr/local/opendomo/addAction.sh; then
			echo "# There are no actions configured. Please, go to Add."
			echo "actions:"
			echo "	addAction.sh	Add"
		else
			echo "# There are no actions configured. Please ask your installer."
		fi
		echo
		exit 0
	fi

	echo "actions:"
	if test -x /usr/local/opendomo/manageActions.sh; then
		echo "	manageActions.sh	Manage actions"
	fi
else
	# SEQUENCE REQUESTED
	if test -x "$SEQPATH/$1"; then
		if ! test -f /var/opendomo/run/$1.pid ; then
			touch /var/opendomo/run/$1.pid
			desc=`grep '#desc' "$SEQPATH/$1" | cut -f2 -d:` 2>/dev/null
			echo "#INFO Launching [$desc]"
			/bin/logevent notice odauto "Action [$desc] started"
			bgshell "/bin/logevent notice odauto 'Action started' ; $SEQPATH/$1 ; /bin/logevent notice odcommon 'Action finished' ; rm /var/opendomo/run/$1.pid"
	
			/usr/local/opendomo/startAction.sh
		else
			/bin/logevent debug odauto "Action [$1] is already active. Ignoring."
		fi
	else
		echo "#ERROR Missing privileges"
		exit 2
	fi
fi
echo
