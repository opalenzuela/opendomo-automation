#!/bin/sh
#desc:Manage rules
#type:local
#package:odauto

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

RULESDIR="/etc/opendomo/rules"

# A rule is a condition (or a set of conditions) and a pair of 
# actions

test -d "$RULESDIR" || mkdir "$RULESDIR"

#if test -z "$1";then
	cd $RULESDIR
	echo "#> Rules available"
	echo "list:editRule.sh	listbox selectable"
	EXISTS=0;
	for r in *.rule; do
		if test -f "$r"; then
			CODE=`echo $r | cut -f1 -d.`
			DESC=`grep '#desc' $r | cut -f2 -d: `
			ACTION=`tail -n1 $r | cut -b2- | cut -f1 -d' '`
			ACTIONDESC=`grep '#desc' /usr/local/opendomo/eventhandlers/$ACTION | cut -f2 -d:`
			test -z "$DESC" && DESC="$CODE"
			echo "	-$CODE	$DESC	rule	$ACTIONDESC"
			EXISTS=1
		fi
	done

	if test "$EXISTS" = "0" ; then
		echo "# There are no rules. Please, go to Add."
	fi

	echo "actions:"
	echo "	addRule.sh	Add"
	echo "	delRule.sh	Delete"
	if test -x /usr/local/opendomo/manageEventHandlers.sh; then
		echo "	manageEventHandlers.sh	Event manager"
	fi	
	echo 
#else
#	echo "#ERR Unexpected parameter $1"
# Nothing. Just ignore.
#fi
echo
