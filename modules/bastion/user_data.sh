#!/bin/bash
# Update system packages
apt update -y
apt

# Install MySQL client
apt install -ymysql-client

# Optional: confirm installation
mysql --version
