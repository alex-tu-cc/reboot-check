#!/bin/bash
#
# This script is prepared to be included.
#

set +x
check_dry_run(){
    if [ "$DRY_RUN" == "1" ]; then
        echo "$@"
    else
        "$@"
    fi
}

func_failed(){
    echo failed!!!;
    exit 1;
}

reboot(){
    [ "$DRY_RUN" != "1" ] && systemctl reboot
}

suspend(){
    [ "$DRY_RUN" != "1" ] && echo $(date +%s -d '+ 15 seconds') > /sys/class/rtc/rtc0/wakealarm
    [ "$DRY_RUN" != "1" ] && systemctl suspend
}

func_update_count_and_suspend(){
    COUNTING=/var/local/count
    local next_count=$(($(cat "$COUNTING")+1)) || true
    echo "success, process to suspend"
    echo $next_count > "$COUNTING"
    suspend
}

func_update_count_and_reboot(){
    COUNTING=/var/local/count
    local next_count=$(($(cat "$COUNTING")+1)) || true
    echo "success, process to reboot"
    echo $next_count > "$COUNTING"
    reboot
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

# $1 wait timer
# $2 notify string
wait_and_notify(){
    local sleep_secs=10
    local i=0
    runs=$(($1/$sleep_secs))
    for ((i; i < $runs; i++ )); do
        sleep $sleep_secs
        notify_user "$2 , count down $i in $runs"
    done


}
# noticifican should be issued after some delay, otherwise it will not shows on screen.
notify_user(){
    [ $# == 0 ] && return
    local xuser_display_pairs=($(who | sed 's/[(|)]/ /g' | awk '{print $1 " " $5}' | grep ":"))
    local i=0
    for(( i=0; i < ${#xuser_display_pairs[@]}; i+=2));
    do
        XAUTHORITY=/home/${xuser_display_pairs[$i]}/.Xauthority DISPLAY=${xuser_display_pairs[$((i+1))]} notify-send -u critical "$1"
    done
    wall "$1"
}

# noticifican should be issued after some delay, otherwise it will not shows on screen.
notify_user_interactive(){
    [ $# == 0 ] && return
    local xuser_display_pairs=($(who | sed 's/[(|)]/ /g' | awk '{print $1 " " $5}' | grep ":"))
    local i=0
    for(( i=0; i < ${#xuser_display_pairs[@]}; i+=2));
    do
        XAUTHORITY=/home/${xuser_display_pairs[$i]}/.Xauthority DISPLAY=${xuser_display_pairs[$((i+1))]} zenity --info  --text="$1"
    done
    wall "$1"
}
