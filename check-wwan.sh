#!/bin/sh


MONITOR_STRING="Telecom"
DBUS_MENU_LOG="/tmp/nm-sniffer-log"
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
    [ "$DRY_RUN" != "1" ] && systemctl reboot
}

echo $(($(cat /var/local/count)+1)) > /var/local/count || true
while [ ! -e $DBUS_MENU_LOG ];
do
    sleep 3
    echo waitting $DBUS_MENU_LOG
done
grep $MONITOR_STRING $DBUS_MENU_LOG && reboot
echo not reboot ....
