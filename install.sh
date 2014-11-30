#!/bin/bash
#
#
#
CPATH="/etc/openmqtt"
LOGPATH="/var/log/openmqtt"


echo "* Stoping OpenMQTT"
service openmqtt stop




#============================================================
#fix outdated conf location
if [ -f "/etc/minion.conf" ]; then
	if [ ! -d /etc/openmqtt ]; then
		mkdir /etc/openmqtt
	fi
	mv /etc/minion.conf /etc/openmqtt/openmqtt.conf
fi 
if [ -f "/opt/minion/key" ]; then
	mv /opt/minion/key "$CPATH/key"
fi
if [ -f "/opt/minion/key.pub" ]; then
	mv /opt/minion/key.pub "$CPATH/key.pub"
fi
rm /etc/motd

if [ -d "/etc/minion" ]; then
	mv /etc/minion /etc/openmqtt
	mv /etc/openmqtt/minion.conf /etc/openmqtt/openmqtt.conf
fi







#Read install path from conf file or create it with defaults
if [ -f "$CPATH/openmqtt.conf" ]; then
	echo "Upgrading OpenMQTT"

	MPATH='/opt/openmqtt'
	if [ -f "/etc/openmqtt/openmqtt.conf" ]; then
		MPATH=$(awk -F "=" '/MPATH/ {print $2}' /etc/openmqtt/openmqtt.conf)
	fi

	ID=''
	if [ -f "/etc/openmqtt/openmqtt.conf" ]; then
		ID=$(awk -F "=" '/ID/ {print $2}' /etc/openmqtt/openmqtt.conf)
	fi


	echo "[Global]" > "/etc/openmqtt/openmqtt.conf"
	echo "ID=$ID" > "/etc/openmqtt/openmqtt.conf"
	echo "PATH=$MPATH" > "/etc/openmqtt/openmqtt.conf"

else
	echo "Installing OpenMQTT"
	echo "[Global]" > "/etc/openmqtt/openmqtt.conf"
	echo "ID=0" > "/etc/openmqtt/openmqtt.conf"
	echo "PATH=/opt/openmqtt" > "/etc/openmqtt/openmqtt.conf"
fi



#============================================================
# SETUP PROPER USER GROUP
# openmqtt USER GROUP
/bin/egrep  -i "^openmqtt" /etc/group
if [ $? -eq 0 ]; then
   echo "* User Group 'openmqtt' already exists, nothing to do."
else
   echo "* User Group 'openmqtt' does not exist, creating now."
   groupadd openmqtt
fi


#============================================================
# ADD LOGGING DIRECTORY
if [ ! -d "$LOGPATH" ]; then
	echo "Adding Logging"
	mkdir $LOGPATH
	chgrp -R openmqtt $LOGPATH
	chmod -R 775 $LOGPATH
fi




#============================================================
# SSL CERTIFICATE

if [ ! -f $CPATH/key ]; then
	echo "* Generating openmqtt Key, this may take a while..."
	ssh-keygen -b 4096 -N "" -O clear -O permit-port-forwarding -t rsa -f "$CPATH/key"
	chmod 600 $CPATH/key
fi





#============================================================
# PI CLEANUP
#echo "* Updating Repository"
#apt-get update
#
#REMOVE MISC UNNEEDED PACKAGES FROM RASPBERRY PI'S
##http://brandonb.io/creating-your-own-minimalistic-rasbian-image-for-the-raspberry-pi
#echo "* Remove Misc Packages and Development"
#rm -rf python_games
#apt-get remove x11-common midori lxde lxde-common lxde-icon-theme omxplayer raspi-config -y
#apt-get remove `sudo dpkg --get-selections | grep "\-dev" | sed s/install//` -y
##apt-get remove `sudo dpkg --get-selections | grep -v "deinstall" | grep python | sed s/install//` -y
#apt-get remove `sudo dpkg --get-selections | grep -v "deinstall" | grep x11 | sed s/install//` -y
#apt-get remove gcc-4.4-base:armhf gcc-4.5-base:armhf gcc-4.6-base:armhf -y
#apt-get remove libraspberrypi-doc xkb-data fonts-freefont-ttf -y
#apt-get autoremove -y
#apt-get clean







#============================================================
# INSTALL/CONFIGURE EXTERNAL UTILITIES

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







#============================================================
# INSTALL OLD - openmqtt APPLICATION
MPATH='/opt/openmqtt'

if [ ! -d $MPATH ]; then
	mkdir $MPATH
	mkdir $MPATH/bin
	mkdir $MPATH/log
fi

echo "* Copying Bin Utilities and Scripts"
rm -rf $MPATH/bin
cp -rf opt-openmqtt-bin/ $MPATH/

echo "* Fixing Permissions"
chgrp -R openmqtt $MPATH
chmod -R 775 $MPATH


echo "* Configuring Cron"
#add hourly script
cp -f etc-cron/hourly /etc/cron.hourly/openmqtt
chmod +x /etc/cron.hourly/openmqtt
#add daily script
cp -f etc-cron/daily /etc/cron.daily/openmqtt
chmod +x /etc/cron.daily/openmqtt
#add weekly script
cp -f etc-cron/weekly /etc/cron.weekly/openmqtt
chmod +x /etc/cron.weekly/openmqtt
#add monthly script
cp -f etc-cron/monthly /etc/cron.monthly/openmqtt
chmod +x /etc/cron.monthly/openmqtt


echo "* Restarting Cron"
service cron restart




#============================================================
# INSTALL NEW - openmqtt APPLICATION

# install client
mv usr-bin/openmqtt-client /usr/bin/openmqtt-client
chmod +x /usr/bin/openmqtt-client


#install service
mv init.d/openmqtt /etc/init.d/openmqtt
chmod +x /etc/init.d/openmqtt
update-rc.d openmqtt defaults





#============================================================
# FAIL2BAN CONFIGURATION
if [ -d /etc/fail2ban ]; then
	if [ -f /etc/fail2ban/action.d/mosquitto.conf ]; then
		echo "* Fail2Ban already configured, updating..."
		mv conf/fail2ban.conf /etc/fail2ban/action.d/mosquitto.conf
	else
		echo "* Configuring Fail2Ban"
		mv conf/fail2ban.conf /etc/fail2ban/action.d/mosquitto.conf

		/bin/egrep  -i "ssh-mosquitto" /etc/fail2ban/jail.conf
		if [ $? -eq 0 ]; then
		   echo "* Fail2Ban Jail already configured, nothing to do."
		else
		   echo "* Fail2Ban Jail needing configuration..."

		   echo "# notify mqtt broker" >> /etc/fail2ban/jail.conf
		   echo "[ssh-mosquitto]" >> /etc/fail2ban/jail.conf
		   echo "enabled  = true" >> /etc/fail2ban/jail.conf
		   echo "filter   = sshd" >> /etc/fail2ban/jail.conf
		   echo "action   = mosquitto[name=ssh]" >> /etc/fail2ban/jail.conf
		   echo "logpath  = /var/log/auth.log" >> /etc/fail2ban/jail.conf
		fi
	fi
	echo "* Restarting Fail2Ban"
	service fail2ban restart
fi






#============================================================
# INSTALL MORAN ROOT CERTIFICATE AUTHORITY
if [ ! -f /usr/local/share/ca-certificates/MoranCA.crt ]; then
	echo "* Installing Root Certiciate"
	cp -f MoranCA.crt /usr/local/share/ca-certificates/
	update-ca-certificates
fi









#============================================================
#rm -rf /opt/openmqtt


echo "* Starting OpenMQTT"
service openmqtt start


echo "Installation Complete... Enjoy your openmqtt!"