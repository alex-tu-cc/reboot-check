#!/bin/bash
# reference : http://ah.thameera.com/connecting-to-mobile-broadband-from-a-terminal/
set -x
LOG=/var/local/count
RETRY_LOG=/var/local/retry
DRY_RUN=0;
usage() {
cat << EOF
usage: $0 options
    
    -h|--help print this message
    -dry-run tryrun
EOF
exit 1
}

while [ $# -gt 0 ]                                                                                   
do
    case "$1" in
        -h | --help)
            usage 0
            exit 0
            ;;  
        --dry-run)
            DRY_RUN=1;
            ;;  
        *)
	usage
       esac
       shift
done

check_dry_run(){
    if [ "$DRY_RUN" == "1" ]; then
        echo "$@"
    else
        "$@"
    fi
}

func_get_and_reboot(){
    echo "success, process to reboot"
    local count
    count=$(cat $LOG)
    count=$((count+1)) 
    echo $count > $LOG
    check_dry_run systemctl reboot
    exit 1
}

func_failed(){
    echo failed!!!;
    exit 1;
}

# give some time incase manually stop is needed.
check_dry_run sleep 30
set -x
for retry in $(seq 1 30);
do 
        # check gsm available
        gsm_status=$(nmcli -f TYPE,STATE dev | awk '/gsm/ {print $2}')
        if [ "$gsm_status" == "disconnected" ]; then
            gsm_uuid=$(nmcli -p con | awk '/gsm/ {print $(NF-2)}') || func_failed 
            # connect 
            nmcli -t con up uuid "$gsm_uuid"
            # try ping
            ping -c 3 www.google.com || func_failed
            func_get_and_reboot
        else
            echo $retry > $RETRY_LOG
            continue              
        fi 
    sleep 1
done;
func_failed
