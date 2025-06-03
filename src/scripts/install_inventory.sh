#!/bin/bash

echo "Installing Inventory App..."
echo $MOVIES_DB_HOST

echo "export MOVIES_DB_HOST=${MOVIES_DB_HOST}" >> /home/vagrant/.bashrc
echo "export MOVIES_DB_NAME=${MOVIES_DB_NAME}" >> /home/vagrant/.bashrc
echo "export MOVIES_DB_USER=${MOVIES_DB_USER}" >> /home/vagrant/.bashrc
echo "export MOVIES_DB_PASSWORD=${MOVIES_DB_PASSWORD}" >> /home/vagrant/.bashrc
echo "export MOVIES_DB_PORT=${MOVIES_DB_PORT}" >> /home/vagrant/.bashrc
echo "export INVENTORY_PORT=${INVENTORY_PORT}" >> /home/vagrant/.bashrc
echo "export MOVIES_HOST=${MOVIES_HOST}" >> /home/vagrant/.bashrc
echo "export MOVIES_TABLE=${MOVIES_TABLE}" >> /home/vagrant/.bashrc

source ~/.bashrc

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
  sudo -u postgres createuser --superuser $MOVIES_DB_USER
 
  sudo -u postgres psql -c "ALTER USER vagrant WITH PASSWORD '$MOVIES_DB_PASSWORD';"

  sudo -u postgres createdb -O $MOVIES_DB_USER $MOVIES_DB_NAME

  

# Start PostgreSQL service and enable on boot
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create the movies table in movies_db as the postgres user
sudo -u postgres psql $MOVIES_DB_NAME <<EOF
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
sudo -u vagrant \
  MOVIES_DB_HOST=$MOVIES_DB_HOST \
  MOVIES_DB_NAME=$MOVIES_DB_NAME \
  MOVIES_DB_USER=$MOVIES_DB_USER \
  MOVIES_DB_PASSWORD=$MOVIES_DB_PASSWORD \
  MOVIES_DB_PORT=$MOVIES_DB_PORT \
  INVENTORY_PORT=$INVENTORY_PORT \
  MOVIES_HOST=$MOVIES_HOST \
  MOVIES_TABLE=$MOVIES_TABLE \
  pm2 start server.js --name movies-server 
  


sudo -u vagrant pm2 save
