#!/bin/sh
#desc:Manage rules
#type:local
#package:odauto

# Copyright(c) 2015 OpenDomo Services SL. Licensed under GPL v3 or later

RULESDIR="/etc/opendomo/rules"

# A rule is a condition (or a set of conditions) and a pair of 
# actions

test -d "$RULESDIR" ||mkdir "$RULESDIR"

#if test -z "$1";then
	cd $RULESDIR
	echo "#> Rules available"
	echo "list:editRule.sh	selectable"
	EXISTS=0;
	for r in *.rule; do
		if test -f "$r"; then
			DESC=`grep '#desc' $r | cut -f2 -d: `
			echo "	-$r	$DESC	rule"
			EXISTS=1
		fi
	done

	if test "$EXISTS" = "0" ; then
		echo "# There are no rules. Please, go to Add."
	fi

	echo "actions:"
	echo "	addRule.sh	Add"
	echo "	delRule.sh	Delete"
	echo 
#else
#	echo "#ERR Unexpected parameter $1"
# Nothing. Just ignore.
#fi
echo
