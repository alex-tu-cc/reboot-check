#!/bin/bash
#
# This script is prepared to be included.
#

reboot(){
    [ "$DRY_RUN" != "1" ] && systemctl reboot
}


# $1 is the filter bash command, ex. grep -e "^w"
# default check interval is 5 secs
wait_nmcli(){
    
     #if you need to wait networkmanager
    while [ 1 ]; do
        if nmcli d | eval "$1"; then
            break
        else
            sleep 5
        fi
    done
}


notify_user(){
    [ $# == 0 ] && return
    local xuser_display_pairs=($(who | sed 's/[(|)]/ /g' | awk '{print $1 " " $5}' | grep ":"))
    for(( i=0; i < ${#xuser_display_pairs[@]}; i+=2));
    do
        XAUTHORITY=/home/${xuser_display_pairs[$i]}/.Xauthority DISPLAY=${xuser_display_pairs[$((i+1))]} notify-send -u critical "$1"
    done
    wall "$1"
}

