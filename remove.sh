#!/bin/bash

rm -rf /opt/minion

rm -f /etc/init.d/tund

rm -rf /etc/fail2ban


sudo update-rc.d tund remove

apt-get remove fail2ban
sudo update-rc.d fail2ban remove

