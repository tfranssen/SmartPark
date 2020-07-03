# SmartPark

Setup script for Installing clean SmartParks stack on RockPi 4

## To do:
* InfluxDB
* Configure Chripstack using API calls
* Configure Node-red

## Step 1: Download image
Download Armbian image from `https://dl.armbian.com/rockpi-4b/Buster_current` or choose another image from `https://www.armbian.com/rock-pi-4/`  
I use Buster Server kernel 5.4

## Step 2: Write image
Write image to SD card using Balena Etcher

## Step 3: Boot PI and innitial config
Boot RockPI, find IP address on your router or by using NMAP `nmap 192.168.178.0/24`  
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
