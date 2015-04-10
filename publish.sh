#! /bin/bash

VERSION=`cat VERSION.txt`


dput -f ppa:danielheth/hethio-agent ../hethio-agent_$VERSION-1_source.changes


# ===================================
# MOVE ARTIFACTS INTO PLACE
#if [ ! -d ../hethio-agent_artifacts ]; then
#	mkdir ../hethio-agent_artifacts
#fi
#mv ../hethio-agent_* ../hethio-agent_artifacts/
