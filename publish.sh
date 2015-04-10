#! /bin/bash

VERSION=`cat VERSION.txt`

dput ppa:danielheth/hethio-agent ./$VERSION.changes
