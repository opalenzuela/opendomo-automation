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
	for s in *.*
	do
		if test -f $s; then
			code="$s"
			desc=`head -n2 $s | grep desc: | cut -f2 -d:`
			echo "	-$code	$desc	action"
		fi
	done
	if test -z "$code"; then
		echo "#INFO No actions defined. To create one, press Add"
	fi
	echo "actions:"
	echo "	addAction.sh	Add"
	echo "	manageActions.sh	Edit"
	echo "	delAction.sh	Delete"
	exit 0
else
	code="$1"
	SEQ=$SEQPATH/$1
	touch $SEQ
	chmod +x $SEQ
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
	echo '#desc:' $desc | sed 's/+/ /g' >> $SEQ
	echo $steplist | sed -e 's/!/\n/g' -e 's/+/ /g'  -e 's/_/\//g'  -e 's/(OR)/||/g' -e 's/(AND)/&&/g' >> $SEQ
	chmod +x $SEQ
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


echo "#> Timers"
# List of all supported scripts in /usr/local/bin
echo "list:editSequenceTime.sh	iconlist foldable"
echo "	wait.sh+1s	1s	item drag wait	Wait for [1] second"
echo "	wait.sh+5s	5s	item drag wait	Wait for [5] seconds"
echo "	wait.sh+10s	10s	item drag wait	Wait for [10] seconds"
echo "	wait.sh+1m	1m	item drag wait	Wait for [1] minute"
echo
# Only if audio is available
if test -x /usr/local/bin/play.sh; then
	echo "#> Audio"
	echo "list:editSequenceAudio.sh	iconlist foldable"
	echo "	play.sh+beep	beep	item drag play	Play a [beep] sound"
	echo "	play.sh+notify	notify	item drag play	Play a [notify] sound"
	echo "	say.sh+???  	say 	item drag say 	Say [???]"
	echo
fi

# Only if Control directory exists (hence, control devices are configured)
if test -d /etc/opendomo/control/
then
	echo "#> Ports"
	echo "list:editSequencePorts.sh	iconlist foldable"
	cd /etc/opendomo/control/
	for port in `grep  -n "way='out'" */* | cut -f1 -d.`
	do
		values="on,off"
		desc="$port"
		source /etc/opendomo/control/$port.info
		bname=`basename $port`
		pname=`echo $port |  sed 's/\//_/g'`
		echo "	setport.sh+$pname+[$values]	$bname	item drag setport	$desc ???"
	done
	echo
fi

echo "#> Logical operators"
echo "list:editSequenceLogic.sh	iconlist foldable"
echo "	exit+0	Finish	item drag logical 	Finish successfully	"
echo "	exit+1	Abort	item drag logical	Finish with error code"
echo


