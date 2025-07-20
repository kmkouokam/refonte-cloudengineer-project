#!/bin/bash

# Update system packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install wget -y
sudo apt install openjdk-21-jdk -y
java -version

#Add Jenkins Repository
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
     https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
     https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
     /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y

#Start and Enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
# Check Jenkins status
sudo systemctl status jenkins

#Adjust the Firewall
sudo ufw allow 8080
sudo ufw reload
sudo ufw status
