#!/bin/bash

# Update system packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Nginx
sudo apt-get install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# allow Nginx through the firewall
sudo ufw allow 'Nginx Full'
# Optional: confirm installation
nginx -v

cd /tmp
curl -o xray.deb https://s3.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-3.x.deb
sudo dpkg -i xray.deb
sudo apt install -y /tmp/xray.deb

# Start and enable X-Ray daemon
sudo systemctl start xray
sudo systemctl enable xray
sudo systemctl status xray
