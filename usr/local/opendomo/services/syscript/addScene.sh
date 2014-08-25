#!/bin/sh
#desc:Add scene
#package:odhal
#type:local

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CFGPATH="/etc/opendomo/scenes"
CTRLPATH="/var/opendomo/control"


# GUI that creates a scene

if test -z "$1"; then
	# Display ports

	# Organize ports each time
	#/usr/local/opendomo/organizeControlPorts.sh > /dev/null
	
	cd $CTRLPATH
	echo "#> Add scene"
	echo "list:`basename $0`	selectable wizard"
	echo "	:	Select the ports involved in this scene	:"
	for zone in *; do
		if test "$zone" != "*"; then
			description=""
			if test -f /etc/opendomo/zones/$zone
			then
				source /etc/opendomo/zones/$zone
			fi
			if test -z "$description"; then
				description=$zone;
			fi
			for device in *
			do
				echo "	$device	$device	separator"
				cd $device
				for port in *.value
				do
					if test "$port" != "*.value"; then
						pname=`echo $port | cut -f1 -d.`
						desc="";
						source /etc/opendomo/control/$device/$pname.info
						
						if test -z "$desc"; then
							desc="$pname"
						fi
						
						if test "$way" = "out"; then
							echo "	$device/$pname	$desc	port"
						fi
					fi
				done
				cd ..
			done
		fi
	done
	if ! test -z "$desc"; then
		echo "actions:"
		echo "	addScene.sh	Add scene"
	else
		echo "#WARN: No ports found"
		echo "actions:"
		echo "	configureControlPorts.sh	Configure control ports"
	fi
	echo

elif [ "$1" != "save" ]; then

	echo "#> New scene"
	echo "form:`basename $0`	wizard"
	echo "	action	action	hidden	save"
	echo "	:	Write a descriptive name for the scene, so you can find it later on	:"
	echo "	name	Descriptive name	text"
	echo "	ports	ports	hidden	$@"
	echo "actions:"
	echo "	goback	Back"
	echo "	addScene.sh	Next"
	echo

#Code that saves the scene
else
	desc=`echo $2 | sed 's/+/ /g'`
	code=`echo $2 | tr A-Z a-z | sed 's/[^a-zA-Z0-9]//g'`
	plist=`echo $3 | sed -e 's/+/ /g' -e 's/\//_/g' `

	if test -z "$2"; then

		echo "#WARN: Scene name not especified "
		/usr/local/opendomo/addScene.sh
		exit 0
	fi

	if test -e $CFGPATH/$code.conf; then
		echo "#> New scene"
		echo "list:`basename $0`	wizard"
		echo "# Scene already exists"
		echo "actions:"
		echo "	goback	Back"
		echo
		exit 0
	fi

	echo "#desc:$desc" > $CFGPATH/$code.conf
	echo "#dbg_1 $@" >> $CFGPATH/$code.conf
	echo "desc='$desc'" >> $CFGPATH/$code.conf
	echo "plist='$plist'" >> $CFGPATH/$code.conf
	CTRLPATH="/var/opendomo/control"
	for i in $plist; do
		fname=`echo $i | sed -e 's/-/\//' -e 's/_/\//'`
		if test -f $CTRLPATH/$fname.value; then
			VAL=`cat $CTRLPATH/$fname.value`
			if test -z "$VAL"; then
				VAL="on"
			fi
			#echo "# $i stored"
			#echo "$i=$VAL" >> $CFGPATH/$code.conf
			VALUES="$VALUES $i=$VAL"
			#echo "cat $VAL > $CTRLPATH/$i" >> $CFGPATH/$code.conf
		else
			echo "#WARN $CTRLPATH/$fname.value value file missing"
		fi
	done
	echo "values='$VALUES'" >> $CFGPATH/$code.conf

	echo "#> New scene"
	echo "form:`basename $0`	wizard"
	echo "	filename	filename	hidden	$code"
	echo "	:	Scene saved	:"
	echo "	:	If you want to modify the state of each port in this scene, go to Customize scene	:"
	echo "actions:"
	echo "	editScene.sh	Customize scene"
	echo "	manageScenes.sh	Finalizar"
	echo
fi

