#!/bin/bash

i=0
while true; do 
	i=$((i + 1))
	echo $i
	echo 0 > /sys/class/rtc/rtc0/wakealarm
	echo $(date +%s -d '+ 15 seconds') > /sys/class/rtc/rtc0/wakealarm
	if [ $? -ne 0 ]; then
		echo 'cannot write rtc sysfs'
		exit
	fi
	systemctl suspend
	sleep 10
	gdbus introspect --system --dest org.bluez --object-path /org/bluez/hci0 --only-properties | grep Powered | grep -q true
	if [ $? -ne 0 ]; then
		echo 'Powered = false'
		exit
	fi
	sleep 5
done
