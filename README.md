# Minion
Minions are Ubuntu computers or, more likely, Raspberry Pi's configured to run a series of scripts all controlled by the main minion website and exposed via a simple onboard API website.  This project is designed to configure freshly installed OS into a Minion device or upgrade it to the latest scripts and utilities.


## Installing or Updating Minions

>$ wget https://github.com/danielheth/minion/tarball/master

>$ tar -xpvf master

>$ cd danielheth*

The following command will determine if we're upgrading or installing new.

>$ sudo ./installed.sh


## File Structure
To help you understand what is going on and know how to extend this project, here is the file structure I'm using.

- /opt/minion
  - api - Minion-API website exposed on the network
  - bin - various utilities and scripts
  - conf - configuration files for the utilities within bin
  - cache - temporary location for website and other tools
  - logs - results of utilities and other logged data


# Special Notes
I did have to recompile the latest version of Mosquitto for this project to function properly on Raspberry Pi's.