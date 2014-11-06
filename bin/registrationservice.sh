#!/bin/bash
#
# Fake RegistrationService
#

mosquitto_pub -t /minion/register/$1 -m "$2" -h broker.openmqtt.org