#! /bin/bash

python setup.py \
--command-packages=stdeb.command debianize \
--suite `lsb_release -sc`

python setup.py sdist
mv dist/hethio-agent* ../

# dput ppa:danielheth/hethio-agent ../hethio-agent_0.0.1\~ppa4_source.changes