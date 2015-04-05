#!/bin/bash
#
# HethIO Globals
#

BROKER='broker.moranit.com'

MPATH='/opt/hethio'
if [ -f "/etc/hethio/hethio.conf" ]; then
	MPATH=$(awk -F "=" '/PATH/ {print $2}' /etc/hethio/hethio.conf)
fi

ID=''
if [ -f "/etc/hethio/hethio.conf" ]; then
	ID=$(awk -F "=" '/ID/ {print $2}' /etc/hethio/hethio.conf)
fi


DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
HOSTNAME=`hostname -f`


# PUBLISH A MESSAGE TO THE MQTT BROKER
publish () 
{ # Send message to our mqtt broker
	echo "/hethio/$1 => $2"
	mosquitto_pub -t "/hethio/$1" -m "$2" -h $BROKER

	if [ -f "$MPATH/log/hethio.log" ]; then
		echo "$DATETIME [0] Registering Device" >> $MPATH/log/hethio.log
	fi
}


# SUBSCRIBE TO A TOPIC ON THE MQTT BROKER
subscribe () 
{ # Send message to our mqtt broker
	echo "Subscribe to /hethio/$1 > $2"
	mosquitto_sub -t "/hethio/$1" -h $BROKER > $2 &

	if [ -f "$MPATH/log/hethio.log" ]; then
		echo "$DATETIME [0] Registering Device" >> $MPATH/log/hethio.log
	fi
}



# PERFORM ANY LAST MINUTE CHECKS ON GLOBAL VARIABLES
if [ ! -d "$MPATH" ]; then
	echo "ERROR: Unable to find hethio install path."
fi