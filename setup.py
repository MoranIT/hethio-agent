#!/usr/bin/env python
# -*- coding: utf-8 -*-
from setuptools import setup, find_packages
import os
import glob

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
	name='hethio-agent',
	install_requires = [],

	packages = find_packages(),
	py_modules = ['hethio-agent'],
	scripts=['usr-bin/hethio-agent'],
	data_files = [],
	package_data = {
        'hethio_data': ['*.ui', '*.png'],
    },
    include_package_data = True, 
    zip_safe = True,


	author='Daniel H Moran',
	author_email='daniel@moranit.com',
	url='http://github.com/moranit/hethio-agent',
	description='Internet monitoring agent',
	long_description=read('README.rst'),
	license='GPLv3',
	
	version=read('VERSION.txt')
)