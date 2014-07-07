#!/bin/sh
#desc:Manage rules
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

RULESDIR="/etc/opendomo/rules"

#COMMANDS="$COMMANDS,@scripts:Scripts"
#cd /usr/local/opendomo/
#for i in *.sh; do
#	DESC=`grep '#desc' $i | cut -f2 -d:`
#	if test -z "$DESC"; then
#		DESC="$i"
#	fi
#	COMMANDS="$COMMANDS,$i:$DESC"
#done

COMMANDS="updateInstalledPackages.sh:Update installed packages,updateLanguageFiles.sh:Update language files"

if test -d /etc/opendomo/sequences; then
	COMMANDS="$COMMANDS,@seq:Sequences"
	cd /etc/opendomo/sequences
	for i in *; do
		if test "$i" != "*"; then
			desc=`grep '#desc' $i | cut -f2 -d:`
			if test -z "$desc"; then
				desc="$i"
			fi
			COMMANDS="$COMMANDS,$i:$desc"
		fi
	done

	COMMANDS="$COMMANDS,@scenes:Scenes"
	cd /etc/opendomo/scenes
	for i in *; do
		if test "$i" != "*"; then
			desc=`grep '#desc' $i | cut -f2 -d:`
			sname=`echo $i  | cut -f1 -d.`
			if test -z "$desc"; then
				desc="$i"
			fi
			COMMANDS="$COMMANDS,setScene.sh $sname:$desc"
		fi
	done	
fi


# A rule is a condition (or a set of conditions) and a pair of 
# actions

if test -z "$1";then
	echo "#WARN Missing parameter"
else
	if test "$2" = "savedesc" && test -z "$3" ; then
		DESC=`echo $1 | sed 's/+/ /g'`
		code=`echo $1 | tr A-Z a-z | sed 's/[^a-z0-9]//g'`
		FILE="$code.rule"
	else	
		FILE="$1"
	fi
	#Some rule is selected
	if ! test -f $RULESDIR/$FILE; then
		echo "# Creating new rule"
		echo "#INFO Please, go to Requirements"
		if test "$2" = "savedesc"; then
			echo "#!/bin/sh -e" > $RULESDIR/$FILE
		else
			exit 0
		fi
	fi
	case $2 in
		"addcond")
			if ! test -z "$command"; then
				echo "test $command # $command_ $command__ $command___" | sed -e 's/(/\$(/'  -e 's/+/ /g'>> $RULESDIR/$FILE
				echo "#INFO: Requirement added"
				/usr/local/opendomo/editRule.sh $FILE
				exit 0
			fi

		;;
		"savedesc")
			if test -z "$3"; then 
				DESC="`echo $1 | sed 's/+/ /g'`"
			else
				DESC="`echo $3 | sed 's/+/ /g'`"
			fi
			sed -i '/#desc/ d' $RULESDIR/$FILE 
			echo "#desc:$DESC" >> $RULESDIR/$FILE
		;;
		"setifrule")
			sed -i '/#command/ d' $RULESDIR/$FILE
			echo "#command:$3 $4" >> $RULESDIR/$FILE
			IFACT="$3"
			IFPARAM="$4"
		;;
#		"setelserule")
#			ELACT="$3"
#			ELPARAM="$4"
#		;;
	esac

	DESC=`grep '#desc' $RULESDIR/$FILE | cut -f2 -d:`
	# echo "#> General data"
	# echo "form:`basename $0`"
	# echo "	rule	rule	hidden	$FILE"
	# echo "	action	action	hidden	savedesc"
	# echo "	name	Name	text	$DESC"
	# echo "actions:"
	# echo "	`basename $0`	Save"
	# echo

	echo "#> Requirements"
	echo "list:`basename $0`	selectable"
	found=0
	for line in `grep -n ^test $RULESDIR/$FILE | sed 's/ /:/g'`; do
		lineno=`echo $line | cut -f1 -d:`
		desc=`echo $line | cut -f2 -d# | sed 's/:/ /g' `
		echo "	$FILE-$lineno	$desc	condition"
		found=1
	done 
	if test "$found" = "0"; then
		echo "#INFO You must specify a valid requirement"
	fi
	echo "actions:"
	echo "	delRuleCondition.sh	Delete requirements"
	echo


	IFACT=`grep '#command' $RULESDIR/$FILE | cut -f2 -d: | cut -f1 -d' '`
	IFPARAM=`grep '#command' $RULESDIR/$FILE | cut -f2 -d' '`
	echo "#> If all requirements are acomplished"
	echo "form:`basename $0`"

	if test -z "$COMMANDS"; then
		echo "# There are no sequences, please go to manage sequences."
		echo "actions:"
		echo "	manageSequence.sh	Manage sequences"
	else
		echo "	rule	rule	hidden	$FILE"
		echo "	action	action	hidden	setifrule"
		echo "	command	Execute action or sequence	list[$COMMANDS]	$IFACT"
		#echo "	params	Additional parameters (optional)	text	$IFPARAM"
		echo "actions:"
		echo "	`basename $0`	Save"
		echo "	manageRules.sh	Back to list"	
		#echo "	addRuleRequirement.sh	Add requirement"
	fi
	echo
	/usr/local/opendomo/addRuleRequirement.sh $FILE
	
fi
echo
