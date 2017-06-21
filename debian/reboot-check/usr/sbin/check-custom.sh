#!/bin/sh

# https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1647283
# https://bugs.launchpad.net/somerville/+bug/1639117
MONITOR_STRING="ethernet"
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

while [ 1 ]; do
    if nmcli d | grep -e "^w"; then
        break
    else
        sleep 5
    fi
done

echo $(($(cat /var/local/count)+1)) > /var/local/count || true
if nmcli d | grep -e "^w" | grep ethernet; then
    echo "find issue!!!!";
else
    reboot
fi
echo not reboot ....
