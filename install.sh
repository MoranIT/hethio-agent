#!/bin/bash
#
#
#

#Read install path from conf file or create it with defaults
if [ -f "/etc/minion.conf" ]; then
	MPATH=$(awk -F "=" '/MPATH/ {print $2}' /etc/minion.conf)
else
	MPATH="/opt/minion"
	echo "[Global]" > "/etc/minion.conf"
	echo "MPATH=$MPATH" >> "/etc/minion.conf"
fi

if [[ -z "$MPATH" ]]; then
	echo "Invalid path found"
fi
if [ $MPATH="" ]; then
	echo "Invalid path found"
fi




# MINION USER GROUP
/bin/egrep  -i "^minion" /etc/group
if [ $? -eq 0 ]; then
   echo "* User Group 'minion' already exists, nothing to do."
else
   echo "* User Group 'minion' does not exist, creating now."
   groupadd minion
fi

if [ ! -d "$MPATH" ]; then
	echo "Installing Fresh Minion Installation"

	mkdir $MPATH
	chgrp -R minion $MPATH
	chmod -R 775 $MPATH
else
	echo "Updating Existing Minion Installation"
fi




if [ ! -f $MPATH/key ]; then
	echo "* Generating Minion Key, this may take a while..."
	ssh-keygen -b 4096 -N "" -O clear -O permit-port-forwarding -t rsa -f "$MPATH/key"
	chmod 600 $MPATH/key
fi



echo "* Updating Repository"
apt-get update

#http://brandonb.io/creating-your-own-minimalistic-rasbian-image-for-the-raspberry-pi
echo "* Remove Misc Packages and Development"
rm -rf python_games
apt-get remove x11-common midori lxde lxde-common lxde-icon-theme omxplayer raspi-config -y
apt-get remove `sudo dpkg --get-selections | grep "\-dev" | sed s/install//` -y
#apt-get remove `sudo dpkg --get-selections | grep -v "deinstall" | grep python | sed s/install//` -y
apt-get remove `sudo dpkg --get-selections | grep -v "deinstall" | grep x11 | sed s/install//` -y
apt-get remove gcc-4.4-base:armhf gcc-4.5-base:armhf gcc-4.6-base:armhf -y
apt-get remove libraspberrypi-doc xkb-data fonts-freefont-ttf -y
apt-get autoremove -y
apt-get clean




# PYTHON
if [ ! -f /usr/bin/python ]; then
	echo "* Installing Python"
	apt-get install python -y
fi

# PERL
if [ ! -f /usr/bin/perl ]; then
	echo "* Installing Perl"
	apt-get install perl -y
fi

# RUBY
if [ ! -f /usr/bin/ruby ]; then
	echo "* Installing Ruby"
	apt-get install ruby -y
fi






echo "* Creating Minion Directory Structure"
if [ ! -d $MPATH ]; then
	mkdir $MPATH
fi
if [ ! -d $MPATH/log ]; then
	mkdir $MPATH/log
fi
if [ ! -d $MPATH/cache ]; then
	mkdir $MPATH/cache
fi

cp -f README.md $MPATH/
touch $MPATH/log/minion.log


echo "* Updating Message of the Day"
cp -f motd /etc/

echo "* Copying Bin Utilities and Scripts"
rm -rf $MPATH/bin
cp -rf bin/ $MPATH/

echo "* Copying Configurations"
rm -rf $MPATH/conf
cp -rf conf/ $MPATH/

echo "* Configuring Cron"
cp -f cron/hourly /etc/cron.hourly/minion
chmod +x /etc/cron.hourly/minion
cp -f cron/daily /etc/cron.daily/minion
chmod +x /etc/cron.daily/minion
cp -f cron/weekly /etc/cron.weekly/minion
chmod +x /etc/cron.weekly/minion
cp -f cron/monthly /etc/cron.monthly/minion
chmod +x /etc/cron.monthly/minion





# MOSQUITTO
if [ ! -f /etc/apt/sources.list.d/mosquitto-stable.list ]; then
	echo "* Installing Mosquitto-Clients"
	apt-key add conf/mosquitto-repo.gpg.key
	rm conf/mosquitto-repo.gpg.key
	mv conf/mosquitto-stable.list /etc/apt/sources.list.d/
	apt-get install mosquitto-clients -y
else
	echo "* Updating Mosquitto-Clients"
	rm -f conf/mosquitto-repo-gpg.key
	rm -f conf/mosquitto-stable.list
fi






# INSTALL MORAN CERTIFICATE AUTHORITY
if [ ! -f /usr/local/share/ca-certificates/MoranCA.crt ]; then
	echo "* Installing Root Certiciate"
	cp -f conf/MoranCA.crt /usr/local/share/ca-certificates/
	update-ca-certificates
fi



echo "* Fixing Permissions"
chgrp -R minion $MPATH
chmod -R 775 $MPATH
chmod 600 $MPATH/key



echo "* Starting Cron"
service cron restart


echo "Installation Complete... Enjoy your Minion!"