#!/bin/bash
apt-get update
apt-get upgrade -y && sudo apt-get install hostapd ntp dnsmasq build-essential git -y

systemctl stop NetworkManager && systemctl disable NetworkManager

cat > /etc/network/interfaces << EOF
#----- lan interface ( standard maintenance connection via ssh )
allow-hotplug eth0
   iface eth0 inet dhcp

#----- RockPI onboard ( access defined in /etc/hostapd.conf )
allow-hotplug wlan0
   iface wlan0 inet static
        address 10.0.0.1
        netmask 255.255.255.0

#----- LB-Link dongle ( access defined in /etc/wpa_supplicant/wpa_supplicant.conf )
allow-hotplug wlxaca2136650d6
   iface wlxaca2136650d6 inet dhcp

        wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

cat > /etc/wpa_supplicant/wpa_supplicant.conf << EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
ssid="Flamingo"
psk="KennyBeats24"
proto=RSN
key_mgmt=WPA-PSK
pairwise=CCMP
auth_alg=OPEN
}
EOF

cat >> /etc/default/hostapd << EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF
cat > /etc/hostapd/hostapd.conf << EOF
interface=wlan0
driver=nl80211
ssid=SmartParks
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=3
wpa_passphrase=1234567890
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

mv /etc/dnsmasq.conf  /etc/dnsmasq.conf.bak
cat > /etc/dnsmasq.conf << EOF
# Interface to bind to
interface=wlan0
# Specify starting_range,end_range,lease_time
dhcp-range=10.0.0.3,10.0.0.20,12h

# Uncomment and modify the following lines if you don't want to forward dns from the host's /etc/resolv.conf
## disables dnsmasq reading any other files like /etc/resolv.conf for nameservers
#no-resolv
## dns addresses to send to the clients
#server=8.8.8.8
#server=8.8.4.4
EOF

systemctl start hostapd && systemctl enable hostapd
systemctl start dnsmasq && systemctl enable dnsmasq

cat > /etc/network/interfaces << EOF
#----- lan interface ( standard maintenance connection via ssh )
allow-hotplug eth0
   iface eth0 inet static
        address 192.168.1.1
        netmask 255.255.255.0

#----- RockPI onboard ( access defined in /etc/hostapd.conf )
allow-hotplug wlan0
   iface wlan0 inet static
        address 10.0.0.1
        netmask 255.255.255.0

#----- LB-Link dongle ( access defined in /etc/wpa_supplicant/wpa_supplicant.conf )
allow-hotplug wlxaca2136650d6
   iface wlxaca2136650d6 inet dhcp

        wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

#####NAT en Forwarding#####
# wlan0 is LAN
# wlxaca2136650d6 is WAN
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i wlan0 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -o wlxaca2136650d6 -j MASQUERADE
iptables -A FORWARD -i wlxaca2136650d6 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o wlxaca2136650d6 -j ACCEPT

apt-get install iptables-persistent -y 

iptables-save > /etc/iptables/rules.v4

#####Chirpstack installeren#####
apt install mosquitto mosquitto-clients redis-server redis-tools postgresql -y

echo "create role chirpstack_as with login password 'dbpassword';
create role chirpstack_ns with login password 'dbpassword';
create database chirpstack_as with owner chirpstack_as;
create database chirpstack_ns with owner chirpstack_ns;
\c chirpstack_as
create extension pg_trgm;
create extension hstore;
\q" | sudo -u postgres psql

apt install apt-transport-https dirmngr -y

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1CE2AFD36DBCCA00 
echo "deb https://artifacts.chirpstack.io/packages/3.x/deb stable main" | sudo tee /etc/apt/sources.list.d/chirpstack.list
apt update
apt install chirpstack-gateway-bridge
systemctl start chirpstack-gateway-bridge
systemctl enable chirpstack-gateway-bridge
apt install chirpstack-network-server

cat > /etc/chirpstack-network-server/chirpstack-network-server.toml << EOF
[general]
log_level=4

[postgresql]
dsn="postgres://chirpstack_ns:dbpassword@localhost/chirpstack_ns?sslmode=disable"

[network_server]
net_id="000000"

  [network_server.band]
  name="EU_863_870"

  [[network_server.network_settings.extra_channels]]
  frequency=867100000
  min_dr=0
  max_dr=5

  [[network_server.network_settings.extra_channels]]
  frequency=867300000
  min_dr=0
  max_dr=5

  [[network_server.network_settings.extra_channels]]
  frequency=867500000
  min_dr=0
  max_dr=5

  [[network_server.network_settings.extra_channels]]
  frequency=867700000
  min_dr=0
  max_dr=5

  [[network_server.network_settings.extra_channels]]
  frequency=867900000
  min_dr=0
  max_dr=5

EOF

systemctl start chirpstack-network-server
systemctl enable chirpstack-network-server
#	journalctl -f -n 100 -u chirpstack-network-server
apt install chirpstack-application-server

cat > /etc/chirpstack-application-server/chirpstack-application-server.toml << EOF
[general]
log_level=4

[postgresql]
dsn="postgres://chirpstack_as:dbpassword@localhost/chirpstack_as?sslmode=disable"

  [application_server.external_api]
  jwt_secret="JTopwCWDI9BjEZO5VgCfxm2rjKpNUUjD0RkeSy9/DTs="
EOF
systemctl start chirpstack-application-server
systemctl enable chirpstack-application-server
#journalctl -f -n 100 -u chirpstack-application-server
##### Install InfluxDB and create DB#####
wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
echo "deb https://repos.influxdata.com/debian buster stable" | tee /etc/apt/sources.list.d/influxdb.list
apt update && apt install influxdb -y
systemctl unmask influxdb
systemctl start influxdb && systemctl enable influxdb

echo "CREATE DATABASE SmartParks" | influx

##### Install Node-red #####
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
systemctl start nodered.service

systemctl enable nodered.service

echo "Script done! reboot to finish setup. Connect to WiFi Smartparks, PI IP = 10.0.0.1"
