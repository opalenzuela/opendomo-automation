#!/bin/sh
#desc:Manage rules
#type:local
#package:odauto

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

RULESDIR="/etc/opendomo/rules"

# Without parameters, back to Add Rule
if test -z "$1"; then
	addRule.sh
	exit
else
	# 4 parameters, we are posting data
	if ! test -z "$3"; then
		RULE=$RULESDIR/$1.rule
		code="$1"
		desc="$2"
		action="$3"
		echo "#!/bin/sh -e" > $RULE
		echo '#desc:' $desc >> $RULE
		echo $4 | sed -e 's/+/ /g' -e 's/!/\n/g' -e 's/(DOLLAR)/\$/g' >> $RULE
		echo "#$action" >> $RULE
		chmod +x $RULE
	else
		# Else, just load file
		code=$1
		RULE=$RULESDIR/$code.rule
		touch $RULE
		desc=`head -n2 $RULE | grep '#desc' | cut -f2 -d:`
		action=`tail -n1 $RULE | cut -b2-`
	fi
fi

# Events and Actions (duplicated from ADDRULE)
cd /usr/local/opendomo/eventhandlers
for i in *.sh ; do
	if test -x $i; then
		descevent=`head -n3 $i | grep desc | cut -f2 -d:`
		COMMANDS="$COMMANDS,$i:$descevent"
	fi
done
if test -d /etc/opendomo/actions; then
	COMMANDS="$COMMANDS,@seq:Actions"
	cd /etc/opendomo/actions
	for i in *; do
		if test "$i" != "*"; then
			descaction=`grep '#desc' $i | cut -f2 -d:`
			if test -z "$descaction"; then
				descaction="$i"
			fi
			COMMANDS="$COMMANDS,$i:$descaction"
		fi
	done
fi

echo "#> Details"
echo "form:`basename $0`	hidden"
echo "	code	Code	hidden	$code"
echo "	desc	Description	text	$desc"
echo "	action	Action	list[$COMMANDS]	$action"
echo "	rules	Rules	hidden	$rules"
echo "actions:"
echo "	editRule.sh	Done"
echo 

echo "#> Conditions"
echo "list:ruleListContainer.sh	detailed"
for i in `grep ^test $RULE | sed  -e 's/ /+/g' `
do
	cmdid=`echo $i | cut -b6-`
	val1=`echo $i | cut -f2 -d+ | sed 's/[^a-zA-Z0-9\.\(\)\/]//g' `
	comp=`echo $i | cut -f3 -d+ | sed -e 's/=/equal/g' -e 's/-gt/greater/g' -e 's/-lt/smaller/g' `
	val2=`echo $i | cut -f4 -d+ `
	script=`echo $val1 | sed  's/[^a-zA-Z0-9\.\/]//g' `
	if test -f $script; then
		desc=`grep '#desc' $script | cut -f2 -d:` 
	else
		desc=`grep '#desc' /usr/local/opendomo/bin/$script | cut -f2 -d:` 
	fi
	test -z "$desc" && desc=$script
	

	#comments=`echo $i | cut -f2 -d# | sed 's/+/ /g'`
	echo "	-$cmdid 	$desc	condition $comp	$val2 "
done
echo "actions:"
echo "	goback	Back"
echo "	manageRules.sh	Save"
echo "	executeRule.sh	Test"
echo "	editDetails.sh	Details"
echo 

echo "#> Time conditions"
echo "list:editConditionsTime.sh	iconlist foldable"
#echo "	sepTime		Time	separator	Time"
echo "	(minute.sh)+[0-59]	Minute	item drag time"
echo "	(hour.sh)+[0-23]	Hour	item drag time"
echo "	(day.sh)+[1-31]	Day 	item drag time"
echo "	(weekday.sh)+[0-7]	Weekday	item drag time"
echo "	(month.sh)+[1-12]	Month	item drag time"
echo

if test -d /etc/opendomo/control/ ; then
	echo "#> Ports"
	echo "list:editConditionsPorts.sh	iconlist foldable"
	cd /etc/opendomo/control/
	#echo "	sepPorts		Ports 	separator	Ports"
	for port in */*.info; do
		if test -f $port; then
			tag="light"
			values="on,off"
			source $port
			test -z "$desc" && desc=$port
			pname=`echo $port | cut -f1 -d.`
			echo "	(/var/opendomo/control/$pname)+[$values]	$desc	item drag port $tag"
		fi
	done

fi
echo

