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

 # Create the 'vagrant' PostgreSQL role with superuser privileges
  sudo -u postgres createuser --superuser vagrant
 
  sudo -u postgres psql -c "ALTER USER vagrant WITH PASSWORD 'vagrant';"

  sudo -u postgres createdb -O vagrant movies_db

# Start PostgreSQL service and enable on boot
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create the movies table in movies_db as the postgres user
sudo -u postgres psql movies_db <<EOF
CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255),
  description TEXT
);
EOF

# Copy app files from /vagrant (synced folder) to /home/vagrant/app
# mkdir -p /home/vagrant/app
# cp /src/inventory-app/server.js /home/vagrant/app/
# cp /src/inventory-app/queries.js /home/vagrant/app/

# Change ownership so PM2 (running as vagrant) can access it
chown -R vagrant:vagrant /home/vagrant/app

# Install dependencies (you need package.json in the same folder if required)
cd /home/vagrant/app
sudo -u vagrant npm install

# Start the app with PM2
sudo -u vagrant pm2 start server.js --name movies-server
sudo -u vagrant pm2 save
