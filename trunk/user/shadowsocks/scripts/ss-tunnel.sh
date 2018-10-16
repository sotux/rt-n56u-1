#!/bin/sh

ss_bin=ss-tunnel
ss_json_file="/tmp/ss-tunnel.json"

ss_server=$(nvram get ss_server)
ss_server_port=$(nvram get ss_server_port)
ss_method=$(nvram get ss_method)
ss_password=$(nvram get ss_key)
ss_reuse_port=$(nvram get ss_reuse_port)

ss_tunnel_remote=$(nvram get ss-tunnel_remote)
ss_tunnel_mtu=$(nvram get ss-tunnel_mtu)
ss_tunnel_reuse_port=$(nvram get ss_reuse_port)
ss_tunnel_local_port=$(nvram get ss-tunnel_local_port)

ss_timeout=$(nvram get ss_timeout)
ss_obfs=$(nvram get ss_obfs)
ss_obfs_param=$(nvram get ss_obfs_param)

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

func_start_ss_tunnel() {
	func_gen_ss_json
	sh -c "$ss_bin -c $ss_json_file -u -l $ss_tunnel_local_port -L $ss_tunnel_remote --mtu $ss_tunnel_mtu --no-delay & "
	return $?
}

func_stop() {
	killall -q $ss_bin
}

case "$1" in
start)
	func_start_ss_tunnel && loger $ss_bin "start done" || loger $ss_bin "start failed"
	;;
stop)
	func_stop
	;;
restart)
	func_stop
	func_start_ss_tunnel
	;;
*)
	echo "Usage: $0 { start | stop | restart }"
	exit 1
	;;
esac
