#!/usr/bin/env python
# -*- coding: utf-8 -*-
from setuptools import setup, find_packages
import os
import glob
from distutils.core import setup
import sys

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read().rstrip()
    
setup(
	name='hethio-agent',
	version=read('VERSION.txt'),
	install_requires = [],

	packages = find_packages(),
	py_modules = ['hethio-agent'],
	scripts=['usr-bin/hethio-agent'],
	data_files = [
		('share/hethio-agent/', glob.glob('hethio_data/*'))
	],
	package_data = {
        'hethio_data': ['*.png'],
    },
    include_package_data = True, 
    zip_safe = True,


	author='Daniel Moran',
	author_email='danielheth@hotmail.com',
	url='http://github.com/moranit/hethio-agent',
	description='Internet monitoring agent',
	long_description=read('README.rst'),
	license='GPLv3',
    
    classifiers=[
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
    ],
)