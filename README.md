# SmartPark

Setup script for Installing clean SmartParks stack on RockPi 4

##Steps 1: 
Download Armbian image from 'https://dl.armbian.com/rockpi-4b/Buster_current' or choose another image from 'https://www.armbian.com/rock-pi-4/' 
I use Buster Server kernel 5.4

##Step 2:
Write image to SD card using Balena etcher

##Step 3:
Boot RockPI, find IP address on your router or by using NMAP 'nmap 192.168.178.0/24'
Change Root password
Make new user

##Step 4:
Install git using 'sudo apt-get update && sudo apt-get install git'

##Step 5:
Clone repo using 'git clone https://github.com/tfranssen/SmartPark' 

##Step 6: 
Configure Wifi AP PAssword, SSID, JWT_secret and database passwords to your liking
Run script using 'sudo bash ./SmartPark/setup.sh' 
Run through node-red script

##Done
You can connect to the RockPI using wifi on SSID SmartParks.
Default ip-address is '10.0.0.1'

Lora Application server '10.0.0.1:8080'
Node-red '10.0.0.1:1880'
