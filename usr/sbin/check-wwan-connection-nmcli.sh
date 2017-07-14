#!/bin/bash
# reference : http://ah.thameera.com/connecting-to-mobile-broadband-from-a-terminal/
set -x
RETRY_LOG=/var/local/retry
DRY_RUN=0;
WAIT_SECS=60
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

for retry in $(seq 1 20);
do
        # check gsm available
        gsm_status=$(nmcli -f TYPE,STATE dev | awk '/gsm/ {print $2}')
        if [ "$gsm_status" == "connected" ]; then
            # try ping
            ping -c 3 www.google.com || exit 1
            exit 0
            break
        elif [ "$gsm_status" == "disconnected" ]; then
            gsm_uuid=$(nmcli -p con | awk '/gsm/ {print $(NF-2)}') || exit 1
            # connect
            nmcli -t con up uuid "$gsm_uuid"
        else
            echo "$retry" > "$RETRY_LOG"
    	sleep 1
            continue
        fi
done;
exit 1
