#!/bin/sh
#desc:Add action
#type:local
#package:odauto

# Copyright(c) 2014 OpenDomo Services SL. Licensed under GPL v3 or later

# When this script is invoked from the web interface, it creates a dummy code
# and then it redirects to the edition form

if test -z "$1"
then
	CODE="act`date +%s`.action"
else
	CODE="$1.action"
fi

SEQPATH="/etc/opendomo/actions"
if ! test -d $SEQPATH; then
	mkdir -p $SEQPATH 2>/dev/null
fi

echo '#!/bin/sh' > $SEQPATH/$CODE
echo '#desc: New action' >> $SEQPATH/$CODE
manageActions.sh $CODE
