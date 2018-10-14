#!/bin/sh

dir_storage="/etc/storage"
dir_dnsmasq="$dir_storage/dnsmasq"
user_dnsmasq_conf="$dir_dnsmasq/dnsmasq.conf"
hostname=`nvram get computer_name`
lan_domain=`nvram get lan_domain`

func_start(){
	sed -i '/srv-host=_vlmcs._tcp/d' $user_dnsmasq_conf
	echo srv-host=_vlmcs._tcp.$lan_domain,$hostname.$lan_domain,1688,0,100 >> $user_dnsmasq_conf
	vlmcsd
	logger -st "vlmcsd" "start"
}

func_stop(){
	sed -i '/srv-host=_vlmcs._tcp/d' $user_dnsmasq_conf
	killall -q vlmcsd
}

case "$1" in
start)
	func_start
	;;
stop)
	func_stop
	;;
restart)
	func_stop
	func_start
	;;
*)
	echo "Usage: $0 { start | stop | restart }"
	exit 1
	;;
esac
