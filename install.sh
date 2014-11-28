#!/bin/bash
#
#
#
CPATH="/etc/minion"
LOGPATH="/var/log/minion"



#============================================================
#fix outdated conf location
if [ -f "/etc/minion.conf" ]; then
	if [ -d /etc/minion ]; then

	else
		mkdir /etc/minion
	fi
	mv /etc/minion.conf /etc/minion/minion.conf
fi 
if [ -f "/opt/minion/key" ]; then
	mv /opt/minion/key "$CPATH/key"
fi
if [ -f "/opt/minion/key.pub" ]; then
	mv /opt/minion/key.pub "$CPATH/key.pub"
fi
rm /etc/motd
rm /etc/cron.hourly/minion
rm /etc/cron.daily/minion
rm /etc/cron.weekly/minion
rm /etc/cron.monthly/minion





#Read install path from conf file or create it with defaults
if [ -f "$CPATH/minion.conf" ]; then
	echo "Upgrading Minion"
else
	echo "Installing Minion"
	echo "[Global]" > "/etc/minion/minion.conf"
fi



#============================================================
# SETUP PROPER USER GROUP
# MINION USER GROUP
/bin/egrep  -i "^minion" /etc/group
if [ $? -eq 0 ]; then
   echo "* User Group 'minion' already exists, nothing to do."
else
   echo "* User Group 'minion' does not exist, creating now."
   groupadd minion
fi


#============================================================
# ADD LOGGING DIRECTORY
if [ ! -d "$LOGPATH" ]; then
	echo "Adding Logging"
	mkdir $LOGPATH
	chgrp -R minion $LOGPATH
	chmod -R 775 $LOGPATH
	touch "$LOGPATH/minion.log"
fi




#============================================================
# SSL CERTIFICATE

if [ ! -f $CPATH/key ]; then
	echo "* Generating Minion Key, this may take a while..."
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
# INSTALL MINION APPLICATION


#echo "* Copying Bin Utilities and Scripts"
#rm -rf $MPATH/bin
#cp -rf bin/ $MPATH/

#echo "* Copying Configurations"
#rm -rf $MPATH/conf
#cp -rf conf/ $MPATH/

#echo "* Configuring Cron"
##add hourly script
#cp -f cron/hourly /etc/cron.hourly/minion
#chmod +x /etc/cron.hourly/minion
##add daily script
#cp -f cron/daily /etc/cron.daily/minion
#chmod +x /etc/cron.daily/minion
##add weekly script
#cp -f cron/weekly /etc/cron.weekly/minion
#chmod +x /etc/cron.weekly/minion
##add monthly script
#cp -f cron/monthly /etc/cron.monthly/minion
#chmod +x /etc/cron.monthly/minion


# install client
mv init.d/minion /etc/init.d/minion
chmod +x /etc/init.d/minion

mv usr-bin/minion-client /usr/bin/minion-client
chmod +x /usr/bin/minion-client

update-rc.d minion defaults





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





#echo "* Fixing Permissions"
#chgrp -R minion $MPATH
#chmod -R 775 $MPATH
#chmod 600 $MPATH/key


#echo "* Starting Cron"
#service cron restart



##============================================================
## REGISTER SYSTEM UPON INSTALLATION
#if [ -f $MPATH/bin/register ]; then
#	cd $MPATH/bin
#	echo "Register system"
#	$MPATH/bin/register
#fi



#============================================================
#rm -rf /opt/minion



echo "Installation Complete... Enjoy your Minion!"