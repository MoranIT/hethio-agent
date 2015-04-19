#! /bin/bash



#===========================
# Add Mosquitto repo
curl -O http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
apt-key add mosquitto-repo.gpg.key
rm mosquitto-repo.gpg.key
cd /etc/apt/sources.list.d/
curl -O http://repo.mosquitto.org/debian/mosquitto-repo.list
apt-get update
cd 


#===========================
# do we need to install the repository?
if [ ! -f /etc/apt/sources.list.d/danielheth-hethio-trusty.list ]; then
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
fi




#===========================
# Remove unNeeded Packages
if [ -f /etc/init.d/raspi-config ]; then
	# GUI-related packages
	pkgs="
	xserver-xorg-video-fbdev
	xserver-xorg xinit
	gstreamer1.0-x gstreamer1.0-omx gstreamer1.0-plugins-base
	gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-alsa
	gstreamer1.0-libav
	epiphany-browser
	lxde lxtask menu-xdg gksu
	xserver-xorg-video-fbturbo
	xpdf gtk2-engines alsa-utils
	netsurf-gtk zenity
	desktop-base lxpolkit
	weston
	omxplayer
	raspberrypi-artwork
	lightdm gnome-themes-standard-data gnome-icon-theme
	qt50-snapshot qt50-quick-particle-examples
	"
	 
	# Edu-related packages
	pkgs="$pkgs
	idle python3-pygame python-pygame python-tk
	idle3 python3-tk
	python3-rpi.gpio
	python-serial python3-serial
	python-picamera python3-picamera
	debian-reference-en dillo x2x
	scratch nuscratch
	raspberrypi-ui-mods
	timidity
	smartsim penguinspuzzle
	pistore
	sonic-pi
	python3-numpy
	python3-pifacecommon python3-pifacedigitalio python3-pifacedigital-scratch-handler python-pifacecommon python-pifacedigitalio
	oracle-java8-jdk
	minecraft-pi python-minecraftpi
	wolfram-engine
	"
	 
	# Remove packages
	for i in $pkgs; do
		echo apt-get -y remove --purge $i
	done
	 
	# Remove automatically installed dependency packages
	echo apt-get -y autoremove
fi





#===========================
# INSTALL
apt-get update
apt-get -y install mosquitto-clients hethio-agent vim




#===========================
# VALIDATE

debInst() {
    dpkg-query -Wf'${db:Status-abbrev}' "$1" 2>/dev/null | grep -q '^i'
}


pkg="mosquitto-clients"
if debInst "$pkg"; then
    echo "$pkg package is installed"
else
    echo "Missing $pkg"
    exit 1
fi


pkg="hethio-agent"
if debInst "$pkg"; then
    echo "$pkg package is installed"
else
    echo "Missing $pkg"
    exit 1
fi


