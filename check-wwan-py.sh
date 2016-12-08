#!/bin/sh
# This script will call a python script to check the items of nm-applet by dbus menu.

MONITOR_STRING="Telecom"
DBUS_MENU_LOG="/home/u/.cache/dbus-menu-nmapplet.log"
LOCAL_LOG=/var/local/$0.log

usage() {
cat << EOF
usage:  options
    
    -h|--help print this message
    -dry-run tryrun
    
EOF
exit 1
}

while [ $# -gt 0 ]
do
    case "" in
        -h | --help)
            usage 0
            exit 0
            ;;  
        --dry-run)
            DRY_RUN=1;
            ;;  
        -s | --string)
            shift;
            MONITOR_STRING=$1
            echo MONITOR_STRING=$MONITOR_STRING
        ;; 
        *)
        usage
       esac
       shift
done

reboot(){
    echo reboot .... 
    rm $DBUS_MENU_LOG
    [ "$DRY_RUN" != "1" ] && systemctl reboot
}

python nm_indicator_dbusmenu_introspect.py&
echo $(($(cat /var/local/count)+1)) > /var/local/count || true
sleep 3
grep $MONITOR_STRING $DBUS_MENU_LOG && reboot
echo not reboot ....
