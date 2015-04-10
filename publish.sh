#! /bin/bash

VERSION=`cat VERSION.txt`


dput -f ppa:danielheth/hethio-agent ../hethio-agent_$VERSION.changes
