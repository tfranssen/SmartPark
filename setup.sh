#!/bin/bash

##### Update and install packages #####
apt-get update
apt-get upgrade -y && sudo apt-get install hostapd ntp dnsmasq build-essential git -y

#####Stop and disable networkmanager for stability #####
systemctl stop NetworkManager && systemctl disable NetworkManager

##### Write network settings #####
cat interfaces.conf > /etc/network/interfaces 

##### Write Wifi (WPA) settings #####
cat wifisettings.conf > /etc/wpa_supplicant/wpa_supplicant.conf 

##### Configure hostapd (Accespoint) #####
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\""  >> /etc/default/hostapd
cat hostapd.conf > /etc/hostapd/hostapd.conf

##### Configure DNSMasq #####
mv /etc/dnsmasq.conf  /etc/dnsmasq.conf.bak
cat dnsmasq.conf > /etc/dnsmasq.conf 

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
apt-get install iptables-persistent -y 
iptables-save > /etc/iptables/rules.v4

##### Install Chripstack dependencies #####
apt install mosquitto mosquitto-clients redis-server redis-tools postgresql apt-transport-https dirmngr-y

##### Configure Postgres database #####
echo "create role chirpstack_as with login password 'dbpassword';
create role chirpstack_ns with login password 'dbpassword';
create database chirpstack_as with owner chirpstack_as;
create database chirpstack_ns with owner chirpstack_ns;
\c chirpstack_as
create extension pg_trgm;
create extension hstore;
\q" | sudo -u postgres psql

##### Add chripstack repo #####
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1CE2AFD36DBCCA00 
echo "deb https://artifacts.chirpstack.io/packages/3.x/deb stable main" | sudo tee /etc/apt/sources.list.d/chirpstack.list

##### Install Chripstack gateway bridge #####
apt update && apt install chirpstack-gateway-bridge
systemctl start chirpstack-gateway-bridge && systemctl enable chirpstack-gateway-bridge

##### Install Chripstack network server #####
apt install chirpstack-network-server

cat chripstack-network-server.toml > /etc/chirpstack-network-server/chirpstack-network-server.toml 

systemctl start chirpstack-network-server && systemctl enable chirpstack-network-server

##### Install Chripstack application server #####
apt install chirpstack-application-server
cat chirpstack-application-server.toml > /etc/chirpstack-application-server/chirpstack-application-server.toml
systemctl start chirpstack-application-server && systemctl enable chirpstack-application-server

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

echo "Script done! Reboot to finish setup. Connect to WiFi Smartparks, PI IP = 10.0.0.1"