#!/bin/bash

UPDATE=false

usage() { echo "Usage: $0 [-u]" 1>&2; exit 1; }

while getopts ":u" o; do
    case "${o}" in
        u)
            UPDATE=true
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


if [ "$UPDATE" != true ]; then
echo "Installing Fresh Minion Installation"

echo "- Installing Python"
apt-get install python

echo "- Installing Perl"
apt-get install perl

echo "- Installing WebServer and PHP"
apt-get install lighttpd
service lighttpd stop
apt-get install php5-common php5-cgi php5
lighty-enable-mod fastcgi-php

echo "- Creating Minion Directory"
mkdir -f /opt/minion
mkdir -f /opt/minion/logs

else
echo "Updating Existing Minion Installation"

echo "- Stopping WebServer"
service lighttpd stop

fi

echo "- Removing Old Files"
rm -rf /var/www
rm -rf /etc/speedtest
rm -rf /usr/local/bin/speedtest-cli
rm -rf /etc/ddclient
rm -rf /usr/sbin/ddclient

echo "- Configuring WebServer"
cp -f lighttpd.conf /etc/lighttpd/

echo "- Copying Bin Utilities and Scripts"
rm -rf /opt/minion/bin
cp -rf bin/ /opt/minion/

echo "- Copying Configurations"
rm -rf /opt/minion/conf
cp -rf conf/ /opt/minion/

echo "- Copying minion-api website"
rm -rf /opt/minion/api
cp -rf api/ /opt/minion/

echo "- Configuring Cron"
cp -f cron/hourly /etc/cron.hourly/minion
cp -f cron/daily /etc/cron.daily/minion
cp -f cron/weekly /etc/cron.weekly/minion
cp -f cron/monthly /etc/cron.monthly/minion


echo "- Starting WebServer"
service lighttpd start


echo "Enjoy your Minion!"