#!/bin/sh
#desc:Configure control ports
#package:odauto
#type:local
 
# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

CTRLPATH="/var/opendomo/control"
CFGPATH="/etc/opendomo/control"
ZONEDIR="/etc/opendomo/zones"

# Loading zones list
mkdir -p $ZONEDIR
cd $ZONEDIR
for z in *; do
	if test "$z" != "*"
	then
		. $ZONEDIR/$z
		if test -z "$ZONES"; then
			ZONES="$z:$description"
		else
			ZONES="$ZONES,$z:$description"
		fi
	else
		ZONES="main"
	fi
done

POSSV="on-off,ON-OFF,00-10-20-30-40-50-60-70-80-90-100"

TAGDIR=/etc/opendomo/tags
if ! test -d $TAGFILE
then
	/usr/local/opendomo/manageTags.sh
fi

cd $TAGDIR
for t in *; do
	if test -z $TAGS
	then
		TAGS="$t:$t"
	else
		TAGS="$TAGS,$t:$t"
	fi
done

# Inputs types
TYPES="switch:switch,pushbutton:pushbutton,analog:analog"

cd $CTRLPATH
#PORTS=`find -type p | sed 's/\.\///g' | sort`

#PORT=`echo $1 | sed 's/\./\//'`
PORT="$1"

# -----------------------------------------------------------------------------
# No params -> first execution: display port list
# -----------------------------------------------------------------------------
found=0
if test -z "$PORT"
then
	echo "#> Select port"
	echo "list:`basename $0`	listbox filterable"
	cd $CFGPATH
	for device in *; do
		if test -d "$device"; then
			if test "$device" != "*"; then 
				cd $device
				echo "	$device	$device	separator"
				for port in *.info; do
					if test -f $port; then
						desc=`echo "$port" | cut -f1 -d.`
						source $CFGPATH/$device/$port
						echo "	-$device/$port	$desc	port sub $tag"
						found=1
					fi
				done
				cd ..
			fi
		fi
	done

	if test "$found" = 0
	then
		echo "#WARN: No ports found"
		echo "actions:"
		if test -x /usr/local/opendomo/manageControlDevices.sh; then
			echo "	manageControlDevices.sh	Add control device"
		fi
		echo
		exit 0
	fi
	echo "action:"
	echo
else
# -----------------------------------------------------------------------------
# One parameter -> second call: display form
# -----------------------------------------------------------------------------
	if test -z "$2";
	then
		# mkdir -p $CFGPATH/`echo $PORT | cut -f1 -d/` 2>/dev/null

		# Load configuration, if exists.
		if test -f $CFGPATH/$PORT
		then
			source $CFGPATH/$PORT
		else
			#chmod u+w $CTRLPATH/$PORT.info 2>/dev/null
			#. $CTRLPATH/$PORT.info
			echo "#WARN: No configuration was found"
		fi

		# We obtain the name of the port, if not saved
		if test -z "$desc"; then
			# In desc file, from an old version
			if test -f $CFGPATH/$PORT.desc; then
				desc=`cat $CFGPATH/$PORT.desc`
			else
				# otherwise, from the port's ID
				desc="$PORT"
			fi
		fi

		echo "#> Configure ${way}put port"
		echo "form:`basename $0`"
		echo "	port	Port	readonly	$1"
		echo "	desc	Name	text	$desc"
		echo "	status	Status	list[enabled:enabled,disabled:disabled]	enabled"
		echo "	way	way	hidden	$way"

		# If is a output
		if test "$way" = "out"
		then
			pv=`echo $values| sed 's/,/-/g'`
			echo "	values	Possible values	list[$POSSV]	$pv"
			echo "	zone	Zone	list[$ZONES]	$zone"
			echo "	tag	Tag	list[$TAGS]	$tag"

		# If is a input
		elif test "$way" = "in"
		then
			echo "	units	Units	text	$units"
			echo "	values	Values	hidden	none"
			echo "	zone	Zone	list[$ZONES]	$zone"
			echo "	type	Type	list[$TYPES]	$type"
			echo "	tag	Tag	list[$TAGS]	$tag"
		else
			echo "#ERR: No way specified"
		fi


# -----------------------------------------------------------------------------
# Many parameters -> third call: SAVE
# -----------------------------------------------------------------------------
	else

		# Create new configuration
		touch $CFGPATH/$PORT
		chmod 0644 $CFGPATH/$PORT

		pv=`echo $values | sed 's/-/,/g'`
		desc=`echo $desc | sed 's/+/ /g'`
		rm $CFGPATH/$PORT.desc
		echo "desc='$desc'"	 	> $CFGPATH/$PORT
		echo "status='$3'"  	>> $CFGPATH/$PORT
		echo "way='$way'"    	>> $CFGPATH/$PORT
		echo "units='$units'" 	>> $CFGPATH/$PORT
		echo "values='$pv'" 	>> $CFGPATH/$PORT
		echo "zone='$zone'" 	>> $CFGPATH/$PORT
		echo "tag='$tag'" 		>> $CFGPATH/$PORT
		echo "type='$type'" 	>> $CFGPATH/$PORT

		echo "#INF: Configuration saved"
		echo
		
		/usr/local/opendomo/configureControlPorts.sh
	fi
fi
echo
