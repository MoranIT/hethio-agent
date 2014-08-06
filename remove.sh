#!/bin/bash

rm -rf /opt/minion

rm -f /etc/init.d/tund

rm -rf /etc/fail2ban


update-rc.d tund remove

apt-get remove fail2ban iptables-persistent -y
update-rc.d fail2ban remove

apt-get autoremove -y

