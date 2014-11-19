#!/bin/sh
#desc:Launch sequence
#type:local
#package:odcommon

# Copyright(c) 2011 OpenDomo Services SL. Licensed under GPL v3 or later

SEQPATH="/etc/opendomo/sequences"
if ! test -d $SEQPATH; then
	mkdir -p $SEQPATH 2>/dev/null
fi


# No parameter. Listing sequences
if test -z "$1"; then
	echo "#> Available sequences"
	echo "list:`basename $0`	simple"
	EXIST=0
	if !  test -d $SEQPATH; then
		mkdir $SEQPATH
	fi
	cd $SEQPATH 
	for i in *; do
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
		if test -x /usr/local/opendomo/addSequence.sh; then
			echo "# There are no sequences. Please, go to Add."
			echo "actions:"
			echo "	addSequence.sh	Add"
		else
			echo "# There are no sequences. Please ask your installer."
		fi
		echo
		exit 0
	fi

	echo "actions:"
	if test -x /usr/local/opendomo/manageSequence.sh; then
		echo "	manageSequence.sh	Manage sequences"
	fi
else
	# SEQUENCE REQUESTED
	if test -x "$SEQPATH/$1"; then
		if ! test -f /var/opendomo/run/$1.pid ; then
			touch /var/opendomo/run/$1.pid
			desc=`grep '#desc' "$SEQPATH/$1" | cut -f2 -d:` 2>/dev/null
			echo "#INFO Launching [$desc]"
			/bin/logevent notice odauto "Sequence [$desc] started"
			bgshell "/bin/logevent notice odauto 'Sequence started' ; $SEQPATH/$1 ; /bin/logevent notice odcommon 'Sequence finished' ; rm /var/opendomo/run/$1.pid"
	
			/usr/local/opendomo/launchSequence.sh
		else
			/bin/logevent debug odauto "Sequence [$1] is already active. Ignoring."
		fi
	else
		echo "#ERROR Missing privileges"
		exit 2
	fi
fi
echo
