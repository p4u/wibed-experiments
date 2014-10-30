#!/bin/sh
### CONFINE WIBED EXPERIMENTS SCRIPT ###
### Unicast experiments ###

hostname=$(cat /proc/sys/kernel/hostname)
ip="$(ip addr show dev br-mgmt | grep inet | awk '{print $2}' | cut -d. -f4 | cut -d / -f1 | awk NR==1)"

printf "Starting WiBED config for node $hostname\n"

printf "Starting range prepare script\n"

uci set wireless.radio1=wifi-device
uci set wireless.radio1.type=mac80211
uci set wireless.radio1.channel=140
uci set wireless.radio1.hwmode=11na
uci set wireless.radio1.htmode=HT20
uci set wireless.radio1.disabled=0

uci set wireless.ap1=wifi-iface
uci set wireless.ap1.mode=ap
uci set wireless.ap1.ifname=ap1
uci set wireless.ap1.device=radio1
uci set wireless.ap1.network=ap1
uci set wireless.ap1.ssid=$hostname

uci set network.ap1=interface
uci set network.ap1.proto=static
uci set network.ap1.ipaddr=1.1.1.1
uci set network.ap1.netmask=255.255.255.0

uci commit wireless
uci commit network

(sleep 15 && reboot) &
