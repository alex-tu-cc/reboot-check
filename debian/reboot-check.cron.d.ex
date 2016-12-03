#
# Regular cron jobs for the reboot-check package
#
0 4	* * *	root	[ -x /usr/bin/reboot-check_maintenance ] && /usr/bin/reboot-check_maintenance
