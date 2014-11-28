#!/bin/bash
#
# Minion Globals
#

BROKER='broker.openmqtt.org'

MPATH='/opt/minion'
if [ -f "/etc/minion/minion.conf" ]; then
	MPATH=$(awk -F "=" '/MPATH/ {print $2}' /etc/minion/minion.conf)
fi

ID=''
if [ -f "/etc/minion/minion.conf" ]; then
	ID=$(awk -F "=" '/ID/ {print $2}' /etc/minion/minion.conf)
fi


DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
HOSTNAME=`hostname -f`


# PUBLISH A MESSAGE TO THE MQTT BROKER
publish () 
{ # Send message to our mqtt broker
	echo "/minion/$1 => $2"
	mosquitto_pub -t "/minion/$1" -m "$2" -h $BROKER

	if [ -f "$MPATH/log/minion.log" ]; then
		echo "$DATETIME [0] Registering Device" >> $MPATH/log/minion.log
	fi
}


# SUBSCRIBE TO A TOPIC ON THE MQTT BROKER
subscribe () 
{ # Send message to our mqtt broker
	echo "Subscribe to /minion/$1 > $2"
	mosquitto_sub -t "/minion/$1" -h $BROKER > $2 &

	if [ -f "$MPATH/log/minion.log" ]; then
		echo "$DATETIME [0] Registering Device" >> $MPATH/log/minion.log
	fi
}



# PERFORM ANY LAST MINUTE CHECKS ON GLOBAL VARIABLES
if [ ! -d "$MPATH" ]; then
	echo "ERROR: Unable to find minion install path."
fi