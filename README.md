# SmartPark

Setup script for Installing clean SmartParks stack on RockPi 4.

Hardware:
 * RockPI 4b
 * sD card 64 GB
 * Kingston A2000 250GB NVMe SSD
 * LB Link Wifi dongle
 * Lorix Wifx gateway 4db antenna

Configures:
 * Pi as accespoint over built-in wireless interface (with DHCP)
 * Uses External wireless interfaces for internet connection
 * Ethernet wired interface as 192.168.1.1 for communication with Lorix gateway
 
Software:
 * Hostapd
 * NTP
 * DNSMASQ
 * Mosquitto
 * Redis
 * Postgresql
 * Chirpstack gateway bridge
 * Chirpstack network server
 * Chirpstack application server
 * InfluxDB 
 * Node-red

## To do:
* Configure Chripstack using API calls
* Configure Node-red

## Step 1: Download image
Download Armbian image from `https://dl.armbian.com/rockpi-4b/Buster_current` or choose another image from `https://www.armbian.com/rock-pi-4/`  
I use Buster Server kernel 5.4

## Step 2: Write image
Write image to SD card using Balena Etcher

## Step 3: Boot PI and innitial config
Boot RockPI, find IP address on your router or by using NMAP `nmap -T4 -F 192.168.178.0/24`  
Change Root password  
Make new user

## Step 4: Install Git
Install git using `sudo apt-get update && sudo apt-get install git`

## Step 5: Clone repo
Clone repo using `git clone https://github.com/tfranssen/SmartPark` 

## Step 6:  Configure and run script
Configure Wifi AP PAssword, SSID, JWT_secret and database passwords to your liking  
Run script using `sudo bash ./SmartPark/setup.sh`  
Run through node-red script

## Done
You can connect to the RockPI using wifi on SSID SmartParks.  
Default ip-address is `10.0.0.1`  
  
Lora Application server `10.0.0.1:8080`  
Node-red `10.0.0.1:1880`

## Configure Chripstack using Postman
Import collection from `https://www.getpostman.com/collections/c84e5a7326cb25e768aa`  
Log in in Chirpstack `Username: admin password:admin`  
Change password  
Create API key in Chirpstack and copy to clipboard  
Copy key in Collection Authorization tab (Right click on Collection, Authoriztion, Bearer token, paste key)  
Set Base-URL in Variables (Right click on Collection, Variables, Base-URL, paste ip @ current value)  
Click on Run Colletion and click Run  (Collection runner opens)  
Click Run SmartParks  

## Configure Node-red
Install packages (manage palette):
* influxdb
* wordlmap
* node-red-dashboard

Import flows:
https://flows.nodered.org/collection/t-mAbk3CoowS



