modprobe iwlwifi connector_log=0x1
sleep 2
ip link set wlan6 up
sleep 1
#iw dev wlan0 connect Mypoi
iw dev wlan6 connect NETGEAR67-5G
#iw dev wlan2 connect Huawei5G
sleep 1
dhclient wlan6

