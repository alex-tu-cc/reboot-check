#!/bin/bash
# reference : http://ah.thameera.com/connecting-to-mobile-broadband-from-a-terminal/
set -x
LOG=/var/local/count
RETRY_LOG=/var/local/retry
DRY_RUN=0;
WAIT_SECS=60
# default cycle 30
usage() {
cat << EOF
usage: $0 options

    -h|--help print this message
    -dry-run tryrun
    --cycle the test cycle number
    --wait_secs the waiting time before checking.
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
        --cycle)
            shift;
            export CYCLE=$1;
	    ;;
        --wait_secs)
            shift;
            WAIT_SECS=$1;
            ;;
        *)
	usage
       esac
       shift
done

source check-common.sh

while [ 1 ]; do
    # give some time incase manually stop is needed.
    check_dry_run wait_and_notify $WAIT_SECS "$(cat /var/local/count) times S3 passed"

    for retry in $(seq 1 60);
    do
            # check gsm available
            gsm_status=$(nmcli -f TYPE,STATE dev | awk '/gsm/ {print $2}')
            if [ "$gsm_status" == "disconnected" ]; then
                gsm_uuid=$(nmcli -p con | awk '/gsm/ {print $(NF-2)}') || func_failed
                # connect
                nmcli -t con up uuid "$gsm_uuid"
                # try ping
                ping -c 3 www.google.com || func_failed
                func_update_count_and_suspend
                break
            else
                echo "$retry" > "$RETRY_LOG"
        	sleep 1
                continue
            fi
    done;
done
