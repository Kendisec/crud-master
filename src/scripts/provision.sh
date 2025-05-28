#!/bin/bash

# Update system
sudo apt-get update -y

# Install dependencies
sudo apt-get install -y curl gnupg build-essential

# Install Node.js (latest LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Install PostgreSQL
sudo apt-get install -y postgresql postgresql-contrib

# Start PostgreSQL service and enable on boot
sudo systemctl enable postgresql
sudo systemctl start postgresql
