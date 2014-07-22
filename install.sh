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

echo "- Installing lighttpd WebServer"
apt-get install lighttpd
service lighttpd stop
apt-get install php5-common php5-cgi php5
lighty-enable-mod fastcgi-php
#chown www-data:www-data /var/www
#chmod 775 /var/www
#usermod -a -G www-data pi
rm /var/www/index.lighttpd.html

else
echo "Updating Existing Minion Installation"
service lighttpd stop

fi

cp lighttpd.conf /etc/lighttpd/
service lighttpd start


echo "Copying minion-api website into place"
cp ./index.php /var/www/
cp ./vendor /var/www/

echo "Enjoy your Minion!"