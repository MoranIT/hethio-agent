#!/bin/bash
#
#
#
CPATH="/etc/hethio"
LOGPATH="/var/log/hethio"


echo "* Stoping HethIO"
service hethio stop




#============================================================
#fix outdated conf location
if [ -d "/etc/openmqtt" ]; then
	mv /etc/openmqtt /etc/hethio
	mv /etc/hethio/openmqtt.conf /etc/hethio/hethio.conf
fi

if [ -d "/opt/openmqtt" ]; then
	mv /opt/openmqtt /opt/hethio
fi

if [ -d "/var/log/openmqtt" ]; then
	mv /var/log/openmqtt /var/log/hethio
fi

if [ -f "/etc/init.d/openmqtt" ]; then
	rm /etc/init.d/openmqtt
fi

if [ -f "/etc/init.d/minion" ]; then
	rm /etc/init.d/minion
fi

if [ -f "/etc/rc0.d/K20minion" ]; then
	rm /etc/rc0.d/K20minion
fi
if [ -f "/etc/rc0.d/K20openmqtt" ]; then
	rm /etc/rc0.d/K20openmqtt
fi
if [ -f "/etc/rc1.d/K20minion" ]; then
	rm /etc/rc1.d/K20minion
fi
if [ -f "/etc/rc1.d/K20openmqtt" ]; then
	rm /etc/rc1.d/K20openmqtt
fi
if [ -f "/etc/rc2.d/K20minion" ]; then
	rm /etc/rc2.d/K20minion
fi
if [ -f "/etc/rc2.d/K20openmqtt" ]; then
	rm /etc/rc2.d/K20openmqtt
fi
if [ -f "/etc/rc3.d/K20minion" ]; then
	rm /etc/rc3.d/K20minion
fi
if [ -f "/etc/rc3.d/K20openmqtt" ]; then
	rm /etc/rc3.d/K20openmqtt
fi
if [ -f "/etc/rc4.d/K20minion" ]; then
	rm /etc/rc4.d/K20minion
fi
if [ -f "/etc/rc4.d/K20openmqtt" ]; then
	rm /etc/rc4.d/K20openmqtt
fi
if [ -f "/etc/rc5.d/K20minion" ]; then
	rm /etc/rc5.d/K20minion
fi
if [ -f "/etc/rc5.d/K20openmqtt" ]; then
	rm /etc/rc5.d/K20openmqtt
fi
if [ -f "/etc/rc6.d/K20minion" ]; then
	rm /etc/rc6.d/K20minion
fi
if [ -f "/etc/rc6.d/K20openmqtt" ]; then
	rm /etc/rc6.d/K20openmqtt
fi











#Read install path from conf file or create it with defaults
if [ -f "$CPATH/hethio.conf" ]; then
	echo "Upgrading HethIO"

	MPATH='/opt/hethio'
	if [ -f "/etc/hethio/hethio.conf" ]; then
		MPATH=$(awk -F "=" '/MPATH/ {print $2}' /etc/hethio/hethio.conf)
	fi

	ID=''
	if [ -f "/etc/hethio/hethio.conf" ]; then
		ID=$(awk -F "=" '/ID/ {print $2}' /etc/hethio/hethio.conf)
	fi


	echo "[Global]" > "/etc/hethio/hethio.conf"
	echo "ID=$ID" >> "/etc/hethio/hethio.conf"
	echo "PATH=$MPATH" >> "/etc/hethio/hethio.conf"

else
	echo "Installing HethIO"
	echo "[Global]" > "/etc/hethio/hethio.conf"
	echo "ID=0" >> "/etc/hethio/hethio.conf"
	echo "PATH=/opt/hethio" >> "/etc/hethio/hethio.conf"
fi



#============================================================
# SETUP PROPER USER GROUP
# hethio USER GROUP
/bin/egrep  -i "^hethio" /etc/group
if [ $? -eq 0 ]; then
   echo "* User Group 'hethio' already exists, nothing to do."
else
   echo "* User Group 'hethio' does not exist, creating now."
   groupadd hethio
fi


#============================================================
# ADD LOGGING DIRECTORY
if [ ! -d "$LOGPATH" ]; then
	echo "Adding Logging"
	mkdir $LOGPATH
	chgrp -R hethio $LOGPATH
	chmod -R 775 $LOGPATH
fi




#============================================================
# SSL CERTIFICATE

if [ ! -f $CPATH/key ]; then
	echo "* Generating hethio Key, this may take a while..."
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
# INSTALL OLD - hethio APPLICATION
MPATH='/opt/hethio'

if [ ! -d $MPATH ]; then
	mkdir $MPATH
	mkdir $MPATH/bin
	mkdir $MPATH/log
fi

echo "* Copying Bin Utilities and Scripts"
rm -rf $MPATH/bin
cp -rf opt-hethio-bin/ $MPATH/
mv $MPATH/opt-hethio-bin $MPATH/bin

echo "* Fixing Permissions"
chgrp -R hethio $MPATH
chmod -R 775 $MPATH


echo "* Configuring Cron"
#add hourly script
cp -f etc-cron/hourly /etc/cron.hourly/hethio
chmod +x /etc/cron.hourly/hethio
#add daily script
cp -f etc-cron/daily /etc/cron.daily/hethio
chmod +x /etc/cron.daily/hethio
#add weekly script
cp -f etc-cron/weekly /etc/cron.weekly/hethio
chmod +x /etc/cron.weekly/hethio
#add monthly script
cp -f etc-cron/monthly /etc/cron.monthly/hethio
chmod +x /etc/cron.monthly/hethio


echo "* Restarting Cron"
service cron restart




#============================================================
# INSTALL NEW - hethio APPLICATION

# install client
mv usr-bin/hethio-client /usr/bin/hethio-client
chmod +x /usr/bin/hethio-client


#install service
mv init.d/hethio /etc/init.d/hethio
chmod +x /etc/init.d/hethio
update-rc.d hethio defaults





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
#rm -rf /opt/hethio


echo "* Starting HethIO"
service hethio start


echo "Installation Complete... Enjoy your hethio-agent!"