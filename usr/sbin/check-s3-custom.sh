#!/bin/bash
# reference : http://ah.thameera.com/connecting-to-mobile-broadband-from-a-terminal/
set -x
LOG=/var/local/count
RETRY_LOG=/var/local/retry
DRY_RUN=0;
WAIT_SECS=60
usage() {
cat << EOF
usage: $0 options

    -h|--help       print this message
    -dry-run        tryrun
    --cycle         the test cycle number
    --wait_secs     the waiting time before checking.
    --call          what bash command do you like to call after S3 resume.
                    the return value(\$0) will be check, success:0, failed:1

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
        --call)
            shift;
            CHECK_COMMAND=$1;
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

    if  $CHECK_COMMAND ;then
        func_update_count_and_suspend
        continue
    else
        notify_user_interactive "$CHECK_COMMAND failed"
        exit 1
    fi
done
