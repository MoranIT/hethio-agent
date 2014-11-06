#!/bin/bash
#
# Minion Globals
#

BROKER='broker.openmqtt.org'
MPATH='/opt/minion'

DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
HOSTNAME=`hostname -f`


message () 
{ # Send message to our mqtt broker
	echo "/minion/$1 => $2"
	mosquitto_pub -t "/minion/$1" -m "$2" -h $BROKER -r

	if [ -f "$MPATH/log/minion.log" ]; then
		echo "$DATETIME [0] Registering Device" >> $MPATH/log/minion.log
	fi
}

