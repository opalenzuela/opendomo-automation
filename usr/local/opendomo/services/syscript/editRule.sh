#!/bin/sh
#desc:Manage rules
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

RULESDIR="/etc/opendomo/rules"

# Without parameters, back to Add Rule
if test -z "$1"; then
	addRule.sh
	exit
else
	# 4 parameters, we are posting data
	if ! test -z "$4"; then
		RULE=$RULESDIR/$1
		code="$1"
		desc="$2"
		action="$3"
		echo "#!/bin/sh -e" > $RULESDIR/$code
		echo '#desc:' $desc >> $RULESDIR/$code
		echo $4 | sed -e 's/+/ /g' -e 's/!/\n/g' -e 's/(DOLLAR)/\$/g' >> $RULESDIR/$code
		echo $action >> $RULESDIR/$code
		chmod +x $RULESDIR/$code
	else
		# Else, just load file
		code=$1
		RULE=$RULESDIR/$1
		desc=`head -n2 $RULE | grep '#desc' | cut -f2 -d:`
		action=`grep -v ^test $RULE | tail -n1`
	fi
fi

echo "#> Hidden form"
echo "form:`basename $0`	hidden"
echo "	code	Code	text	$code"
echo "	desc	Description	text	$desc"
echo "	action	Action	text	$action"
echo "	rules	Rules	text	$rules"

echo "#> Conditions"
echo "list:ruleListContainer.sh"
for i in `grep ^test $RULE | sed  -e 's/ /+/g' `
do
	val1=`echo $i | cut -f2 -d+ | sed 's/[^a-zA-Z0-9\.]//g' `
	comp=`echo $i | cut -f3 -d+ | sed -e 's/=/equal/g' -e 's/-gt/greater/g' -e 's/-lt/smaller/g' `
	val2=`echo $i | cut -f4 -d+ `
	desc=`grep '#desc' /usr/local/opendomo/bin/$val1 | cut -f2 -d:` 
	#comments=`echo $i | cut -f2 -d# | sed 's/+/ /g'`
	echo "	-$val1 	$desc	condition $comp	$val2 "
done
echo "actions:"
echo "	manageRules.sh	Save"
echo 

echo "#> Edit conditions"
echo "list:editConditions.sh	iconlist"
echo "	sepTime		Time	separator	Time"
echo "	minute.sh+[0-59]	Minute	item time"
echo "	hour.sh+[0-23]	Hour	item time"
echo "	day.sh+[1-31]	Day 	item time"
echo "	weekday.sh+[0-7]	Weekday	item time"
echo "	month.sh+[1-12]	Month	item time"
echo

