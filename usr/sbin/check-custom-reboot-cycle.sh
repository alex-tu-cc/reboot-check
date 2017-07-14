#!/bin/bash
set -x
# https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1647283
# https://bugs.launchpad.net/somerville/+bug/1639117
LOCAL_LOG=/var/local/$0.log
TARGET_CYCLES=30
usage() {
cat << EOF
usage:  options
    
    -h|--help print this message
    -dry-run dryrun
    --call what bash command do you like to call after S3 resume.
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
        -s | --string)
            shift;
            MONITOR_STRING=$1
            echo MONITOR_STRING=$MONITOR_STRING
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

wait_and_notify 20 "$(cat /var/local/count) times reboot passed"

echo $(($(cat /var/local/count)+1)) > /var/local/count || true

if [ $(cat /var/local/count) -gt $TARGET_CYCLES ]; then
    echo "reached target cycle $TARGET_CYCLES";
else
    if $CHECK_COMMAND ;then
    ¦   func_update_count_and_reboot
    else
    ¦   notify_user_interactive "$CHECK_COMMAND failed"
    ¦   exit 1
    fi
fi
echo not reboot ....
