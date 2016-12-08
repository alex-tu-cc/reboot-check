#!/bin/bash
# steal the socket of pulseaudio 
sleep 20
pulseaudio_pid=$(ps -ef | grep -m 1 pulseaudio  | awk '{ print $2}');
cat /proc/$pulseaudio_pid/environ | tr \\0 \\n | grep DBUS | tee /home/u/.cache/environ
OTHERS_DBUS_ADDR=`cat /home/u/.cache/environ | tr \\0 \\n | grep DBUS`
echo $OTHERS_DBUS_ADDR
export $OTHERS_DBUS_ADDR
systemctl --user import-environment DBUS_SESSION_BUS_ADDRESS
systemctl --user restart nm-applet-sniffer3.service
