#!/bin/bash
# Update system packages
sudo apt upgrade && update -y

# Install MySQL client
sudo apt install mysql-client -y

# Optional: confirm installation
mysql --version
