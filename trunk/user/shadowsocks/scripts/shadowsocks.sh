#!/bin/sh

ss_bin="ss-redir"
ss_json_file="/tmp/ss-redir.json"

ss_local_port=$(nvram get ss_local_port)
ss_udp=$(nvram get ss_udp)
ss_reuse_port=$(nvram get ss_reuse_port)
ss_server=$(nvram get ss_server)

ss_server_port=$(nvram get ss_server_port)
ss_method=$(nvram get ss_method)
ss_password=$(nvram get ss_key)
ss_mtu=$(nvram get ss_mtu)
ss_timeout=$(nvram get ss_timeout)
ss_obfs=$(nvram get ss_obfs)
ss_obfs_param=$(nvram get ss_obfs_param)

ss_mode=$(nvram get ss_mode)
ss_router_proxy=$(nvram get ss_router_proxy)
ss_lower_port_only=$(nvram get ss_lower_port_only)

loger() {
	logger -st "$1" "$2"
}

get_arg_reuse_port() {
    if [ "$ss_reuse_port" = "1"]; then
        echo "true"
    else
        echo "false"
    fi
}

get_arg_udp() {
	if [ "$ss_udp" = "1" ]; then
		echo "-u"
	fi
}

get_arg_out() {
	if [ "$ss_router_proxy" = "1" ]; then
		echo "-o"
	fi
}

get_wan_bp_list() {
	wanip="$(nvram get wan_ipaddr)"
	[ -n "$wanip" ] && [ "$wanip" != "0.0.0.0" ] && bp="-b $wanip" || bp=""
	if [ "$ss_mode" = "1" ]; then
		bp=${bp}" -B /etc_ro/gfwlist_mode.txt"
	fi
	echo "$bp"
}

get_ipt_ext() {
	if [ "$ss_lower_port_only" = "1" ]; then
		echo '-e "--dport 22:1023"'
	elif [ "$ss_lower_port_only" = "2" ]; then
		echo '-e "-m multiport --dports 53,80,443"'
	fi
}

func_start_ss_redir() {
	sh -c "$ss_bin -c $ss_json_file $(get_arg_udp) -l $ss_local_port --mtu $ss_mtu --no-delay & "
	return $?
}

func_start_ss_rules() {
	ss-rules -f
	sh -c "ss-rules -s $ss_server -l $ss_local_port $(get_wan_bp_list) -d SS_SPEC_WAN_AC $(get_ipt_ext) $(get_arg_out) $(get_arg_udp)"
	return $?
}

func_gen_ss_json() {

cat > "$ss_json_file" <<EOF
{
    "server": "$ss_server",
    "server_port": $ss_server_port,
    "password": "$ss_password",
    "method": "$ss_method",
    "local_address": "0.0.0.0",
    "plugin": "$ss_obfs",
    "plugin_opts": "$ss_obfs_param",
    "timeout": $ss_timeout,
    "reuse_port": $(get_arg_reuse_port)
}

EOF
}

func_start() {
	func_gen_ss_json && \
	func_start_ss_redir && \
	func_start_ss_rules && \
	loger $ss_bin "start done" || { ss-rules -f && loger $ss_bin "start fail!";}
}

func_stop() {
	killall -q $ss_bin
	ss-rules -f && loger $ss_bin "stop"
	gfwlist-mode -off
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
