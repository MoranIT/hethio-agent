#!/bin/bash

if [ ! -d /opt/minion ]; then
	echo "Installing Fresh Minion Installation"

	mkdir /opt/minion
	chgrp -R minion /opt/minion
	chmod -R 775 /opt/minion
else
	echo "Updating Existing Minion Installation"
fi

NAME=`hostname`

read -p "What email should we use for alerts? " EMAIL
read -p "What port number should be configured for the reverse SSH Tunnel? " PORT



if [ ! -f /opt/minion/key ]; then
	echo "* Generating Minion Key, this may take a while..."
	ssh-keygen -b 4096 -N "" -O clear -O permit-port-forwarding -t rsa -f "/opt/minion/key"
	chmod 600 /opt/minion/key
fi



echo "* Updating Repository"
apt-get update

#http://brandonb.io/creating-your-own-minimalistic-rasbian-image-for-the-raspberry-pi
echo "* Remove Misc Packages and Development"
rm -rf python_games
apt-get remove x11-common midori lxde lxde-common lxde-icon-theme omxplayer raspi-config -y
apt-get remove `sudo dpkg --get-selections | grep "\-dev" | sed s/install//` -y
apt-get remove `sudo dpkg --get-selections | grep -v "deinstall" | grep python | sed s/install//` -y
apt-get remove `sudo dpkg --get-selections | grep -v "deinstall" | grep x11 | sed s/install//` -y
apt-get remove gcc-4.4-base:armhf gcc-4.5-base:armhf gcc-4.6-base:armhf -y
apt-get remove libraspberrypi-doc xkb-data fonts-freefont-ttf -y
apt-get autoremove -y
apt-get clean




# PYTHON
if [ ! -d /etc/python ]; then
	echo "* Installing Python"
	apt-get install python -y
fi

# PERL
if [ ! -d /etc/perl ]; then
	echo "* Installing Perl"
	apt-get install perl -y
fi

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

# Fail2Ban
if [ ! -d /etc/fail2ban ]; then
	echo "* Installing Fail2Ban"
	apt-get install fail2ban iptables-persistent -y
	mv -f conf/jail.conf /etc/fail2ban/jail.conf

	sed -i "/#sendername/a sendername = Fail2Ban ($NAME Minion)" /etc/fail2ban/jail.conf
	sed -i "/#destemail/a destemail = $EMAIL" /etc/fail2ban/jail.conf

	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT
	#iptables -A INPUT -p tcp --dport 17472 -j ACCEPT
	#iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	#iptables -A INPUT -p tcp --dport 443 -j ACCEPT
	iptables -A INPUT -j DROP

	chgrp -R minion /opt/minion
	chmod -R 775 /opt/minion

else
	echo "* Updating Fail2Ban"
	mv -f conf/jail.conf /etc/fail2ban/jail.conf	
fi
service fail2ban restart


# Tund
if [ ! -f /etc/init.d/tund ]; then
	echo "* Installing Tund"
	cp init.d/tund /etc/init.d/tund
	chmod +x /etc/init.d/tund
	sudo update-rc.d tund defaults

	chgrp -R minion /opt/minion
	chmod -R 775 /opt/minion

	service tund start
else
	echo "* Updating Tund"
	cp -f init.d/tund /etc/init.d/tund
	service tund restart
fi
sed -i "/:user/a :user => $NAME" /opt/minion/bin/tund
sed -i "/:fwd_port/a :fwd_port => $PORT" /opt/minion/bin/tund















# MINION USER GROUP
/bin/egrep  -i "^minion" /etc/group
if [ $? -eq 0 ]; then
   echo "User Group 'minion' already exists, nothing to do."
else
   echo "User Group 'minion' does not exist, creating now."
   groupadd minion
fi





echo "* Creating Minion Directory Structure"
if [ ! -d /opt/minion ]; then
	mkdir /opt/minion
fi
if [ ! -d /opt/minion/log ]; then
	mkdir /opt/minion/log
fi
if [ ! -d /opt/minion/cache ]; then
	mkdir /opt/minion/cache
fi

cp -f README.md /opt/minion/
touch /opt/minion/log/minion.log


echo "* Updating Message of the Day"
cp -f motd /etc/



echo "* Copying Bin Utilities and Scripts"
rm -rf /opt/minion/bin
cp -rf bin/ /opt/minion/

echo "* Copying Configurations"
rm -rf /opt/minion/conf
cp -rf conf/ /opt/minion/

echo "* Configuring Cron"
cp -f cron/hourly /etc/cron.hourly/minion
chmod +x /etc/cron.hourly/minion
cp -f cron/daily /etc/cron.daily/minion
chmod +x /etc/cron.daily/minion
cp -f cron/weekly /etc/cron.weekly/minion
chmod +x /etc/cron.weekly/minion
cp -f cron/monthly /etc/cron.monthly/minion
chmod +x /etc/cron.monthly/minion


echo "* Fixing Permissions"
chgrp -R minion /opt/minion
chmod -R 775 /opt/minion



echo "* Starting Cron"
service cron restart

# Kickoff Registration Script
#/opt/minion/bin/register

echo "We created an SSH key that needs to be setup on minions.mqtt.me..."
cat "/opt/minion/key.pub"


echo "Enjoy your Minion!"