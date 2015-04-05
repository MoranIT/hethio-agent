#!/bin/bash

rm -rf /opt/hethio
rm -rf /etc/hethio
rm -rf /log/hethio
rm /usr/bin/hethio*

apt-get autoremove -y

rm /etc/rc*/*hethio

