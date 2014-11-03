# Minion-API
Minions are Ubuntu computers or, more likely, Raspberry Pi's configured to run a series of scripts all controlled by the main heth.io website.  This project is designed to configure freshly installed OS into a Minion device or upgrade it to the latest scripts and utilities.


## Installing or Updating Minions

>$ wget https://github.com/danielheth/minion-api/tarball/master

>$ tar -xpvf master

>$ cd danielheth*


The following command will determine if we're upgrading or installing new.

>$ sudo ./installed.sh


## File Structure
To help you understand what is going on and know how to extend this project, here is the file structure I'm using.

- /opt/minion
  - bin - various utilities and scripts
  - conf - configuration files for the utilities within bin
  - cache - temporary location for website and other tools
  - logs - results of utilities and other logged data


## Main Features

* Removes misc packages from a freshly installed Raspberry Pi device during installation.

* Installs Python, Ruby and Perl scripting hosts to run the various utilities we are configuring.

* Installs MoranCA root certificate authority certificate system wide.

* Uses (SpeedTest-CLI)[https://github.com/sivel/speedtest-cli] to capture public IP address and internet connectivity speed information

* Uses (Mosquitto)[https://bitbucket.org/oojah/mosquitto/] Clients to publish MQTT status messages to our central heth.io Cloud Broker.

* Logs device temperature into logs and reports via MQTT.


