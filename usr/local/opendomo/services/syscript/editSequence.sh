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
else
	touch $SEQPATH/$1
	#source $SEQPATH/$1
fi


if test -z "$desc"
then
	desc=`head -n2 $SEQPATH/$1 | grep desc: | cut -f2 -d:`
fi

par1=""
echo "#> Steps in [$desc]"
echo "form:`basename $0`	hidden"
echo "	name	Name	text	$desc"
echo "	steplist	Steps	hidden	"
echo 
echo "list:stepListContainer.sh	detailed"
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
echo "	editSequence.sh	Save sequence"
echo


echo "#> Add new step"
# List of all supported scripts in /usr/local/bin
echo "list:editSequenceSteps.sh	iconlist"

echo "	sepTM	Timers	separator"
echo "	wait.sh+1s	1s	item wait	Wait for [1] second"
echo "	wait.sh+5s	5s	item wait	Wait for [5] seconds"
echo "	wait.sh+10s	10s	item wait	Wait for [10] seconds"
echo "	wait.sh+1m	1m	item wait	Wait for [1] minute"

echo "	sepAU	Audio	separator"
echo "	play.sh+beep	beep	item sound	Play a [beep] sound"
echo "	play.sh+notify	notify	item sound	Play a [notify] sound"
echo "	say.sh+???  	say 	item sound	Say [???]"

#TODO Use one separator per device
echo "	sepDP	Ports 	separator"
cd /etc/opendomo/control/
for port in `grep  -n "way='out'" */* | cut -f1 -d.`
do
	values="on,off"
	desc="$port"
	source /etc/opendomo/control/$port.info
	bname=`basename $port`
	echo "	var/opendomo/control/$port+[$values]	$bname	item port	$desc [$values]"
done
echo


