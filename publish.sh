#! /bin/bash

VERSION=`cat VERSION.txt`


dput ppa:danielheth/hethio-agent ./hethio-agent_$VERSION.changes
