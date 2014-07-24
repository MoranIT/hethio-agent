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
apt-get install python -y

echo "- Installing Perl"
apt-get install perl -y

echo "- Installing WebServer and PHP"
apt-get install lighttpd -y
service lighttpd stop
apt-get install php5-common php5-cgi php5 -y
lighty-enable-mod fastcgi-php

echo "- Creating minion User Group"
groupadd minion
usermod -a -G minion www-data

rm -rf /opt/minion

echo "- Creating Minion Directory"
mkdir /opt/minion
mkdir /opt/minion/log
mkdir /opt/minion/cache
mkdir /opt/minion/cache/ddclient
mkdir /opt/minion/cache/api
mkdir /opt/minion/cache/api/uploads
mkdir /opt/minion/cache/api/compress

touch /opt/minion/log/api.access.log
touch /opt/minion/log/api.error.log

else
echo "Updating Existing Minion Installation"

echo "- Stopping WebServer"
service lighttpd stop

echo "- Backing up Dynamic DNS Configuration"
cp -f /opt/minion/conf/ddclient.conf conf/

fi

cp -f README.md /opt/minion/

echo "- Updating Message of the Day"
cp -f motd /etc/

echo "- Removing Old Web Files"
rm -rf /var/www

echo "- Removing Old speedtest-cli Utility"
if [ -d /etc/speedtest ]; then
rm -rf /etc/speedtest
if [ -f /usr/local/bin/speedtest-cli ]; then
rm -rf /usr/local/bin/speedtest-cli
fi
fi

echo "- Removing Old ddclient Utility"
if [ -d /etc/ddclient ]; then
cp -f /etc/ddclient/ddclient.conf conf/
rm -rf /etc/ddclient
if [ -f /usr/sbin/ddclient ]; then
rm -rf /usr/sbin/ddclient
fi
fi

echo "- Configuring WebServer"
cp -f lighttpd.conf /etc/lighttpd/

echo "- Copying Bin Utilities and Scripts"
rm -rf /opt/minion/bin
cp -rf bin/ /opt/minion/

echo "- Copying Configurations"
if [ ! -f /opt/minion/conf/ddclient.conf ]; then
TIMESTAMP=`date +"%s"`
echo "$TIMESTAMP.minion.moranit.com" >> conf/ddclient.conf
fi
rm -rf /opt/minion/conf
cp -rf conf/ /opt/minion/

echo "- Copying minion-api website"
rm -rf /opt/minion/api
cp -rf api/ /opt/minion/

echo "- Configuring Cron"
cp -f cron/hourly /etc/cron.hourly/minion
chmod +x /etc/cron.hourly/minion
#cp -f cron/daily /etc/cron.daily/minion
#chmod +x /etc/cron.daily/minion
#cp -f cron/weekly /etc/cron.weekly/minion
#chmod +x /etc/cron.weekly/minion
#cp -f cron/monthly /etc/cron.monthly/minion
#chmod +x /etc/cron.monthly/minion


echo "- Fixing Permissions"
chgrp -R minion /opt/minion
chmod -R 775 /opt/minion

echo "- Starting WebServer"
service lighttpd start

echo "- Starting Cron"
service cron restart


echo "Enjoy your Minion!"