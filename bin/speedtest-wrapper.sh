#!/bin/bash

echo "Testing internet speed..."

/opt/minion/bin/speedtest-cli > /opt/minion/logs/speedtest.lastrun.log

TIMESTAMP=`date +"%s"`
DATETIME=`date +"%Y-%m-%d %H:%M:%S"`
RESULTS=`cat /opt/minion/logs/speedtest.lastrun.log | grep 'Mbits/s' | awk -F':' '{print $2}' | awk -F' ' '{print $1;}' | awk 'NR%2{printf $0"|";next;}1'`
DOWNLOAD=`echo $RESULTS | awk -F'|' '{print $1}'`
UPLOAD=`echo $RESULTS | awk -F'|' '{print $2}'`

echo "$DOWNLOAD|$UPLOAD|$DATETIME" >> /opt/minion/logs/speedtest.log  

echo "Done"
