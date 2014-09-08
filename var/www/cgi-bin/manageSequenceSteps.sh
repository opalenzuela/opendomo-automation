#!/bin/sh
echo "Content-type: text/javascript"
echo 
echo
echo "var option_tree = {"


# Is odcontrol properly installed + configured? 
if test -d /etc/opendomo/control
then
	literal=`/usr/local/bin/i18n.sh "Set port"`
	echo "		\"$literal\": {"	
	ARGS1="@setport"
	cd /etc/opendomo/control
	for dev in *; do
		if test -d "$dev"
		then
			cd $dev
			for i in *.info; do
				desc=""
				source ./$i
				if test "$way" = "out" && test "$status" != "disabled"
				then
					if test -z "$desc"
					then
						desc=`echo $i | cut -f2 -d/ | cut -f1 -d.`  
					fi
					pname=`echo $i | cut -f1 -d.`
					#TODO: This should display all possible values for each port
					echo "
					\"$desc\": {
						'ON':\"setport.sh $dev/$pname ON\",
						'OFF':\"setport.sh $dev/$pname OFF\",				
						},"
				fi
			done
			cd ..
		fi
	done
	echo '               }, '
fi

if test -x "/usr/local/opendomo/bin/setallports.sh"; then
	literal=`/usr/local/bin/i18n.sh "Set all"`
	echo "		\"$literal\": {"
	cd /etc/opendomo/tags
	ARGS1="$ARGS1,@setallports.sh"
	for t in *; do
		if test "$t" != "*"; then
			desc=`cat $t`
			echo "
			\"$desc\": {
				'ON':\"setallports.sh $t ON\",
				'OFF':\"setallports.sh $t OFF\",				
				},"
		fi
	done	
	echo '               },'
fi             

# All the sounds in this directory can be called
if test -x /usr/bin/aplay; then
	literal=`/usr/local/bin/i18n.sh "Play"`
	echo "		\"$literal\": {"
	cd /usr/share/sounds
	ARGS1="$ARGS1,@setallports.sh"
	for wav in *; do
		if test $wav != "*"; then
			wavname=`echo $wav | cut -f1 -d.`
			echo "'$wavname':\"play.sh $wav\","

		fi
	done
	echo '               },'
fi             

literal=`/usr/local/bin/i18n.sh "Pause"`
if test -x /usr/local/opendomo/bin/pause.sh
then
	echo "		\"$literal\": {"
	echo '			"seconds": {'
	for i in 1 2 3 4 5 10 15 30 ; do
		echo "				'$i s':'pause.sh $i seconds',"
	done	
	echo '			}, '

	echo '
				"minutes": {'
	for i in 1 2 3 4 5 10 15 30 ; do
		echo "				'$i m':'pause.sh $i minutes',"
	done					
	echo '			}, '

	echo '
				"hours": {'
	for i in 1 2 3 4 5 10 15 30 ; do
		echo "				'$i h':'pause.sh $i hours',"
	done					
	echo '			}, '

	echo '		}, '
fi

#END OF SCRIPT
echo '    };  '
  
