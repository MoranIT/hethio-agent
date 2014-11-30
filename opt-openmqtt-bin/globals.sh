#!/bin/bash
#
# Minion Globals
#

BROKER='broker.openmqtt.org'

MPATH='/opt/openmqtt'
if [ -f "/etc/openmqtt/openmqtt.conf" ]; then
	MPATH=$(awk -F "=" '/PATH/ {print $2}' /etc/openmqtt/openmqtt.conf)
fi

ID=''
if [ -f "/etc/openmqtt/openmqtt.conf" ]; then
	ID=$(awk -F "=" '/ID/ {print $2}' /etc/openmqtt/openmqtt.conf)
fi


DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
HOSTNAME=`hostname -f`


# PUBLISH A MESSAGE TO THE MQTT BROKER
publish () 
{ # Send message to our mqtt broker
	echo "/openmqtt/$1 => $2"
	mosquitto_pub -t "/openmqtt/$1" -m "$2" -h $BROKER

	if [ -f "$MPATH/log/openmqtt.log" ]; then
		echo "$DATETIME [0] Registering Device" >> $MPATH/log/openmqtt.log
	fi
}


# SUBSCRIBE TO A TOPIC ON THE MQTT BROKER
subscribe () 
{ # Send message to our mqtt broker
	echo "Subscribe to /openmqtt/$1 > $2"
	mosquitto_sub -t "/openmqtt/$1" -h $BROKER > $2 &

	if [ -f "$MPATH/log/openmqtt.log" ]; then
		echo "$DATETIME [0] Registering Device" >> $MPATH/log/openmqtt.log
	fi
}



# PERFORM ANY LAST MINUTE CHECKS ON GLOBAL VARIABLES
if [ ! -d "$MPATH" ]; then
	echo "ERROR: Unable to find openmqtt install path."
fi