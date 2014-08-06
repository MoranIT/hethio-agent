#!/bin/bash

rm -rf /opt/minion

rm -f /etc/init.d/tund


update-rc.d tund remove

apt-get autoremove -y

