#!/bin/sh
#desc:Add rule requirement
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later


FILE=$1
if test -z "$FILE"; then
	echo "# Missing param"
else
	echo "#> Add requirement"
	echo "form:manageRules.sh	rowform"
	echo "	rule	rule	hidden	$FILE"
	echo "	action	action	hidden	addcond"
	echo "	command	Command	text"
	echo "actions:"
	echo "	editRule.sh	Add"
fi
echo
	
