#!/bin/bash

# https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1647283
# https://bugs.launchpad.net/somerville/+bug/1639117
LOCAL_LOG=/var/local/$0.log
TARGET_CYCLES=30
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

# if you need to wait networkmanager
#while [ 1 ]; do
#    if nmcli d | grep -e "^w"; then
#        break
#    else
#        sleep 5
#    fi
#done


notify_user(){
    [ $# == 0 ] && return
    local xuser_display_pairs=($(who | sed 's/[(|)]/ /g' | awk '{print $1 " " $5}' | grep ":"))
    for(( i=0; i < ${#xuser_display_pairs[@]}; i+=2));
    do
        XAUTHORITY=/home/${xuser_display_pairs[$i]}/.Xauthority DISPLAY=${xuser_display_pairs[$((i+1))]} notify-send -u critical "$1"
    done
    wall "$1"
}

notify_user "$(cat /var/local/count) times reboot passed"
sleep 90

echo $(($(cat /var/local/count)+1)) > /var/local/count || true
if [ $(cat /var/local/count) -gt $TARGET_CYCLES ]; then
    echo "reached target cycle $TARGET_CYCLES";
else
    reboot
fi
echo not reboot ....
