Description
===========
This cookbook will set the timezone on redhat, centos and fedora.
Requirements
============

Attributes
==========
node['timezone'] = UTC

Usage
=====

Update attribute 'timezone' to timezone needed. Note this cookbook simply adds a symlink from  /usr/share/zoneinfo/UTC to /etc/localtime
