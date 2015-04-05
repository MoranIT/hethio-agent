# heth.io Agent
This application is a daemon that runs on Raspberry PIs, Ubuntu systems and others.  It is designed to monitor various aspects of a users LAN network.

## Installing or Updating

>$ wget https://github.com/moranit/hethio-agent/tarball/master

>$ tar -xpvf master

>$ cd hethio*


The following command will determine if we're upgrading or installing new.

>$ sudo ./installed.sh


## File Structure
To help you understand what is going on and know how to extend this project, here is the file structure I'm using.

/etc/hethio
/usr/bin/hethio
/var/log/hethio/client.log

## Main Features

* Installs Python, Ruby and Perl scripting hosts to run the various utilities we are configuring.

* Installs MoranCA root certificate authority certificate system wide.

* Uses (SpeedTest-CLI)[https://github.com/sivel/speedtest-cli] to capture public IP address and internet connectivity speed information

* Uses (Mosquitto)[https://bitbucket.org/oojah/mosquitto/] Clients to publish MQTT status messages to our central heth.io Cloud Broker.

* Logs device temperature into logs and reports via MQTT.


