#!/bin/sh
#desc:Edit sequence
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

SEQPATH="/etc/opendomo/sequences"


if ! test -d "$SEQPATH"; then
	mkdir -p $SEQPATH
fi

# NO parameters? Invoke manageSequences and exit
if test -z "$1"
then
	/usr/local/opendomo/manageSequences.sh
	exit 0
fi


par1=""
echo "#> Steps in [$SEQDESC]"
echo "list:`basename $0`	selectable "
for line in `grep -nv '^#' $SEQPATH/$FILE | sed 's/ /:/g'`; do
	lineno=`echo $line | cut -f1 -d:`  
	command=`echo $line | cut -f2 -d# | sed -e 's/:/ /g' -e 's/+/ /g'`
	code=`echo $line | cut -f2 -d: | cut -f1 -d.`
	aux=`echo $line | cut -f2`

	echo "	$FILE-$lineno	$command	step $code $aux"
done
if test -z "$command"; then
	echo "#INFO No steps defined yet. Select the action in the menu and press Add."
fi

echo "actions:"
echo "	delSequenceStep.sh	Delete step"
echo


echo "#> Add new step"
# List of all supported scripts in /usr/local/bin
echo "list:editSequenceSteps.sh"
echo "	Timers	separator"
#POSSIBLECOMMANDS="setport.sh setallports.sh wait.sh play.sh"
type="wait"
POSSIBLECOMMANDS="wait.sh+1s wait.sh+5s wait.sh+10s"
for c in $POSSIBLECOMMANDS; do
	# If they exist, and can be executed
	if test -x /usr/local/bin/$c; then
		desc=`grep '#desc' /usr/local/bin/$c | cut -f2 -d:` 2>/dev/null
		if test -z "$desc"; then
			desc="$c"
		fi
		# We add them to the list
		echo "	-$command	$desc	$type"
	fi
done
echo "	Audio	separator"
type="audio"
POSSIBLECOMMANDS="play.sh+1s play.sh+5s play.sh+10s"
for c in $POSSIBLECOMMANDS; do
	# If they exist, and can be executed
	if test -x /usr/local/bin/$c; then
		desc=`grep '#desc' /usr/local/bin/$c | cut -f2 -d:` 2>/dev/null
		if test -z "$desc"; then
			desc="$c"
		fi
		# We add them to the list
		echo "	-$command	$desc	$type"
	fi
done
echo


