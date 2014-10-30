#!/bin/sh
### CONFINE WIBED EXPERIMENTS SCRIPT ###
### Unicast experiments ###

hostname=$(cat /proc/sys/kernel/hostname)
ip="$(ip addr show dev br-mgmt | grep inet | awk '{print $2}' | cut -d. -f4 | cut -d / -f1 | awk NR==1)"
ip6="$(cat /sys/class/net/br-mgmt/address|cut -d: -f6)"
ids=${ids:-"0 1"}

if ! opkg list-installed | grep bmx6; then
	echo "Installing bmx6"
	opkg install http://wibed.ac.upc.edu/wibed/misc/bmx6.ipk
fi

printf "Starting prepare script for $hostname\n"
set -x
devs=""
for i in $ids; do

#	uci set wireless.radio$i=wifi-device
#	uci set wireless.radio$i.type=mac80211
	if [ $i -eq 1 ]; then
		uci set wireless.radio$i.channel=149
		uci set wireless.radio$i.hwmode=11na
		uci set wireless.radio$i.htmode=HT20
		uci set wireless.radio$i.txpower=22
	fi
	uci set wireless.radio$i.disabled=0
	uci set wireless.mesh$i=wifi-iface

	if [ "$1" == "adhoc" ]; then
		uci set wireless.mesh1.mode=adhoc
		uci set wireless.mesh1.bssid=05:CA:FF:EE:BA:BE
		uci set wireless.mesh1.ssid=$hostname
	else
		uci set wireless.mesh$i.mode=mesh
		uci set wireless.mesh$i.mesh_id=wibed
		uci set wireless.mesh$i.mesh_fwding=0
	fi
	uci set wireless.mesh$i.ifname=mesh$i
	uci set wireless.mesh$i.device=radio$i
	uci set wireless.mesh$i.network=mesh$i
	
	uci set network.mesh$i=interface
	uci set network.mesh$i.proto=static
	uci set network.mesh$i.ipaddr="1.1.$i.$ip"
	uci set network.mesh$i.netmask="255.255.255.0"
	uci set network.mesh$i.ip6addr="2012:0:$i:$ip6::1/64"
	devs="$devs dev=mesh$i"
done
	
uci commit wireless
uci commit network
	
if ! grep bmx6 /etc/rc.local; then
	echo "(while pgrep -f mac80211.sh ; do sleep 1; done;
	ulimit -c 20000;
	bmx6 $devs;
	sleep 1;
	bmx6 -c --tunDev main /tun6Address 2012:0:0:$ip6::1/128 /tun4Address 1.1.1.$ip/32;) &" >> /etc/rc.local
fi
	
if ! grep test.sh /etc/crontabs/root; then
	echo '*/5 * * * * sh /root/test.sh' >> /etc/crontabs/root
fi

(sleep 15 && reboot) &
