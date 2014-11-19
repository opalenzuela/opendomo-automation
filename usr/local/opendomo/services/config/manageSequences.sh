#!/bin/sh
#desc:Manage sequences
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

SEQPATH="/etc/opendomo/sequences"


if ! test -d "$SEQPATH"; then
	mkdir -p $SEQPATH
	echo "#!/bin/sh
#desc:Demo
setport.sh dummy/do01 on
wait.sh 10
setport.sh dummy/do01 off"> $SEQPATH/demo.seq
	chown admin:admin -R $SEQPATH 2>/dev/null
	chmod +x $SEQPATH/demo.seq
fi

# Display a list of sequences
echo "#> Available sequences"
echo "list:manageSequenceSteps.sh	selectable"
EXIST=0
cd $SEQPATH
for s in *; do
	if test -x "$s"; then
		TYPE="sequence"
		BNAME=`basename $s`
		desc=`grep '#desc' $s | cut -f2- -d:`

		# Detect if the sequence is being used by rules 
		if grep -q "command:$s" /etc/opendomo/rules/* 2>/dev/null
		then
			TYPE="$TYPE used"
		fi
		# Detect if the sequence is active
		if test -f /var/opendomo/run/$BNAME.pid
		then
			TYPE="$TYPE active"
		fi
		#TODO: Detect if it's being used by eventhandlers or others
		echo "	-$s	$desc	$TYPE"
		EXIST=1;
	fi
done

if test "$EXIST" == "0"; then
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
if test -x /usr/local/opendomo/addSequence.sh; then
	echo "	addSequence.sh	Add"
	echo "	delSequence.sh	Delete"
fi
echo "	launchSequence.sh	Launch sequence"
echo


