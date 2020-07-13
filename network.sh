apt-get upgrade -y && sudo apt-get install hostapd ntp dnsmasq build-essential git iptables-persistent -y

#####Stop and disable networkmanager for stability #####
systemctl stop NetworkManager && systemctl disable NetworkManager

##### Write network settings #####
cat config/interfaces.conf > /etc/network/interfaces 

##### Write Wifi (WPA) settings #####
cat config/wifisettings.conf > /etc/wpa_supplicant/wpa_supplicant.conf 

##### Configure hostapd (Accespoint) #####
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\""  >> /etc/default/hostapd
cat config/hostapd.conf > /etc/hostapd/hostapd.conf

##### Configure DNSMasq #####
mv /etc/dnsmasq.conf  /etc/dnsmasq.conf.bak
cat config/dnsmasq.conf > /etc/dnsmasq.conf 

systemctl start hostapd && systemctl enable hostapd
systemctl start dnsmasq && systemctl enable dnsmasq

##### Configure NAT en Forwarding #####
# wlan0 is LAN
# wlxaca2136650d6 is WAN(inet)
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i wlan0 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -o wlxaca2136650d6 -j MASQUERADE
iptables -A FORWARD -i wlxaca2136650d6 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o wlxaca2136650d6 -j ACCEPT

##### Make persistant after reboot #####
iptables-save > /etc/iptables/rules.v4
