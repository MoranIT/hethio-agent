#! /bin/bash

VERSION=`cat VERSION.txt`

CHANGES=`git shortlog $VERSION..HEAD`
echo $CHANGES > ppa4_source.changes


dput ppa:danielheth/hethio-agent ./ppa4_source.changes
