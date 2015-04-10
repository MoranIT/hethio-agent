#! /bin/bash

python setup.py \
--command-packages=stdeb.command debianize \
--suite `lsb_release -sc`

python setup.py sdist
mv dist/hethio-agent* ./

