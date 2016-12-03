#!/bin/sh


MONITOR_STRING="Telecom"
NM_APPLET_LOG="/home/u/.cache/nm-applet.log"
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
grep $MONITOR_STRING $NM_APPLET_LOG && reboot
