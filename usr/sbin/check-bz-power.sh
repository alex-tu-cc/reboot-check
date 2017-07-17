#!/bin/bash

gdbus introspect --system --dest org.bluez --object-path /org/bluez/hci0 --only-properties | grep Powered | grep -q true
if [ $? -ne 0 ]; then
	echo 'Powered = false'
	exit 1
elif
    exit 0
fi
