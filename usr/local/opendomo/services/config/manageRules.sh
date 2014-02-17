#!/bin/sh
#desc:Manage rules
#type:local
#package:odcommon

RULESDIR="/etc/opendomo/rules"

# A rule is a condition (or a set of conditions) and a pair of 
# actions

#if test -z "$1";then
	cd $RULESDIR
	echo "#> Rules available"
	echo "list:editRule.sh	selectable"
	EXISTS=0;
	for r in *; do
		if test "$r" != "*"; then
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
