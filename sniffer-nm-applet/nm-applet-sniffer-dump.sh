#!/bin/bash
env > /tmp/nm-applet-sniffer.desktop.log
/usr/bin/python /usr/sbin/nm_indicator_dbusmenu_introspect.py 2>&1 | tee /tmp/$(basename "$0").log

