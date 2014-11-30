#!/bin/bash

rm -rf /opt/openmqtt
rm -rf /etc/openmqtt
rm -rf /log/openmqtt
rm /usr/bin/openmqtt*

apt-get autoremove -y

rm /etc/rc*/*openmqtt

