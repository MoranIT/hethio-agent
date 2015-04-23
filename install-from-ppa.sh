#! /bin/bash

debInst() {
    dpkg-query -Wf'${db:Status-abbrev}' "$1" 2>/dev/null | grep -q '^i'
}


#===========================
# do we need to install the repository?
if [ -f /etc/apt/sources.list.d/danielheth-hethio-trusty.list ]; then
	echo "danielheth-hethio-trusty repository is installed"
else
	# for Raspberry Pi's...
	if [ -f /etc/init.d/raspi-config ]; then
		apt-get install python-software-properties -y
		add-apt-repository -y ppa:danielheth/hethio
		rm /etc/apt/sources.list.d/danielheth-hethio-wheezy.list

		echo "deb http://ppa.launchpad.net/danielheth/hethio/ubuntu trusty main" > /etc/apt/sources.list.d/danielheth-hethio-trusty.list
		echo "deb-src http://ppa.launchpad.net/danielheth/hethio/ubuntu trusty main" >> /etc/apt/sources.list.d/danielheth-hethio-trusty.list

	# for Pi's and Ubuntu
	else
		add-apt-repository -y ppa:danielheth/hethio
	fi
	
	apt-get update
fi




#===========================
# PRECHECKS
pkg="mosquitto-clients"
if debInst "$pkg"; then
    echo "$pkg package is installed"
else
    echo "Missing $pkg"
    exit 1
fi



#===========================
# INSTALL
apt-get -y install hethio-agent




#===========================
# VALIDATE
pkg="hethio-agent"
if debInst "$pkg"; then
    echo "$pkg package is installed"
else
    echo "Missing $pkg"
    exit 1
fi


