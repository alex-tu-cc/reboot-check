#!/bin/sh

# default path, could be replaced by -f
CONF_PATH=/usr/share/reboot-check/reboot-check.conf
parse_conf() {
while read propline ; do
   # ignore comment lines
   expr "$propline" : "^#*" && continue
   # if not empty, set the property using declare
   [ ! -z "$propline" ] && run "$propline"
done <  $CONF_PATH
}

run() {
   [ "$DRY_RUN" != "1" ] && $1 2>&1 >> /var/local/log
}
usage() {
cat << EOF
usage:  options

    -h|--help print this message
    -dry-run tryrun
    -f| --file spefic the config file.

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
        -f| --file)
            shift;
            CONF_PATH=$1
            echo "CONF_PATH=$CONF_PATH"
        ;;
        *)
        usage
       esac
       shift
done

parse_conf
