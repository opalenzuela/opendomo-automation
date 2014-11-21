#!/bin/sh
#desc:Manage actions
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

SEQPATH="/etc/opendomo/actions"


if ! test -d "$SEQPATH"; then
	mkdir -p $SEQPATH
fi

# NO parameters? Invoke manageSequences and exit
if test -z "$1"
then
	cd $SEQPATH
	echo "list:`basename $0`	selectable"
	for s in *.seq
	do
		code="$s"
		desc=`head -n2 $s | grep desc: | cut -f2 -d:`
		echo "	-$code	$desc	action"
	done
	echo "actions:"
	echo "	manageActions.sh	Edit"
	echo "	delAction.sh	Delete"
	exit 0
else
	code="$1"
	SEQ=$SEQPATH/$1
	touch $SEQ
	#source $SEQPATH/$1
fi

# Saving action!!
if ! test -z "$3"
then
	code="$1"
	desc="$2"
	steplist="$3"
	SEQ=$SEQPATH/$code
	echo '#!/bin/sh' > $SEQ
	echo '#desc:$desc' >> $SEQ
	echo $steplist | sed -e 's/!/\n/g' -e 's/+/ /g'  -e 's/_/\//g'  -e 's/(OR)/||/g' -e 's/(AND)/&&/g' >> $SEQ
	
fi

if test -z "$desc"
then
	desc=`head -n2 $SEQPATH/$1 | grep desc: | cut -f2 -d:`
fi

par1=""
echo "#> Steps in [$desc]"
echo "form:`basename $0`	hidden"
echo "	code	code	text	$code"
echo "	name	Name	text	$desc"
echo "	steplist	Steps	hidden	"
echo 
echo "list:stepListContainer.sh	detailed"
for line in `grep -v '^#' $SEQ | sed 's/ /+/g'`; do
	command=`echo $line | cut -f1 -d# | sed -e 's/+/ /g' -e 's/||/(OR)/g' -e 's/&&/(AND)/g'`
	text=`echo $line | cut -f2 -d#  | sed -e 's/+/ /g'`
	code=`basename $command | cut -f1 -d.`
	caption=`echo $command | cut -f2 -d' '`
	test -z "$caption" && caption=$command
	echo "	$command	$caption	step $code	$text"
done
if test -z "$command"; then
	echo "#INFO No steps defined yet. Select the action in the menu and press Add."
fi

echo "actions:"
echo "	goback	Back"
echo "	manageActions.sh	Save"
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
if test -x /usr/local/bin/play.sh; then
	echo "	play.sh+beep	beep	item play	Play a [beep] sound"
	echo "	play.sh+notify	notify	item play	Play a [notify] sound"
	echo "	say.sh+???  	say 	item say 	Say [???]"
fi

#TODO Use one separator per device
echo "	sepDP	Ports 	separator"
cd /etc/opendomo/control/
for port in `grep  -n "way='out'" */* | cut -f1 -d.`
do
	values="on,off"
	desc="$port"
	source /etc/opendomo/control/$port.info
	bname=`basename $port`
	pname=`echo $port |  sed 's/\//_/g'`
	echo "	setport.sh+$pname+[$values]	$bname	item setport	$desc ???"
done

echo "	sepLOG	Logical operators	separator"
echo "	exit+0	Finish	item logical 	Finish successfully	"
echo "	exit+1	Abort	item logical	Finish with error code"
echo


