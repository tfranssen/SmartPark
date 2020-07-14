#####NAT en Forwarding#####
# wlan0 is LAN
# wlxaca2136650d6 is WAN
#echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i wlan0 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -o wlxaca2136650d6 -j MASQUERADE
iptables -A FORWARD -i wlxaca2136650d6 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o wlxaca2136650d6 -j ACCEPT
