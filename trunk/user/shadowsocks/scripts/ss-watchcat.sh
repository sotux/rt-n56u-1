#!/bin/sh

China_ping_domain="www.qq.com"
Foreign_wget_domain="http://www.google.com/"
detect_period=300
log_file="/tmp/ss-watchcat.log"
max_log_bytes=100000

loger(){
	[ -f $log_file ] && [ $(stat -c %s $log_file) -gt $max_log_bytes ] && rm -f $log_file
	time=$(date "+%H:%M:%S")
	echo "$time ss-watchcat $1" >> $log_file
}

detect_shadowsocks(){
	wget --spider --quiet --timeout=3 $Foreign_wget_domain > /dev/null 2>&1
	[ "$?" = "0" ] && return 0 || return 1
}

restart_apps(){
	/usr/bin/shadowsocks.sh restart >/dev/null 2>&1 && loger "Problem decteted, restart shadowsocks."
}

[ "$(pidof ss-watchcat.sh)" != "$$" ] && exit 1

while true; do
	sleep $detect_period
	if [ "$(nvram get ss_watchcat)" != "1" ] || [ "$(nvram get ss_router_proxy)" != "1" ] || [ "$(nvram get ss_enable)" != "1" ]; then
		continue
	fi
	tries=0
	ss_need_restart=1
	while [ $tries -lt 3 ]; do
		if /bin/ping -c 1 $China_ping_domain -W 1 >/dev/null 2>&1 ; then
			detect_shadowsocks
			if [ "$?" = "0" ]; then
				loger "No Problem." && ss_need_restart=0 && break
			elif [ "$?" = "1" ]; then
				tries=$((tries+1))
			fi
		else
			loger "Network Error." && ss_need_restart=0 && break
		fi
	done
	[ $ss_need_restart -eq 1 ] && restart_apps
done
