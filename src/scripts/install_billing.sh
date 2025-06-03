#!/bin/bash

echo "Installing Billing App..."
echo $ORDERS_DB_USER

echo "export ORDERS_DB_USER=${ORDERS_DB_USER}" >> /home/vagrant/.bashrc
echo "export ORDERS_DB_PASSWORD=${ORDERS_DB_PASSWORD}" >> /home/vagrant/.bashrc
echo "export ORDERS_HOST=${ORDERS_HOST}" >> /home/vagrant/.bashrc
echo "export ORDERS_DB_NAME=${ORDERS_DB_NAME}" >> /home/vagrant/.bashrc
echo "export ORDERS_DB_HOST=${ORDERS_DB_HOST}" >> /home/vagrant/.bashrc
echo "export ORDERS_DB_PORT=${ORDERS_DB_PORT}" >> /home/vagrant/.bashrc
echo "export BILLING_PORT=${BILLING_PORT}" >> /home/vagrant/.bashrc
echo "export RABBITMQ_HOST=${RABBITMQ_HOST}" >> /home/vagrant/.bashrc
echo "export ORDERS_TABLE=${ORDERS_TABLE}" >> /home/vagrant/.bashrc
echo "export BILLING_QUEUE=${BILLING_QUEUE}" >> /home/vagrant/.bashrc

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
  sudo -u postgres createuser --superuser vagrant
  sudo -u postgres createdb -O vagrant orders

# Start PostgreSQL service and enable on boot
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create PostgreSQL user and database
sudo -u postgres psql movies_db <<EOF
CREATE TABLE order (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  number_of_items INTEGER,
  total_amount INTEGER,
);
EOF

# Install Erlang (required for RabbitMQ)
sudo apt-get install -y erlang

# Add RabbitMQ signing key and repo
curl -fsSL https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/rabbitmq-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/rabbitmq-archive-keyring.gpg] https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list

# Update repo and install RabbitMQ
sudo apt-get update -y
sudo apt-get install -y rabbitmq-server

# Enable and start RabbitMQ
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

# Copy app files from /vagrant (synced folder) to /home/vagrant/app
mkdir -p /home/vagrant/app
cp /src/billing-ap/server.js /home/vagrant/app/
cp /src/billing-ap/consumer.js /home/vagrant/app/

# Change ownership so PM2 (running as vagrant) can access it
chown -R vagrant:vagrant /home/vagrant/app

# Install dependencies (you need package.json in the same folder if required)
cd /home/vagrant/app
sudo -u vagrant npm install

# Start the app with PM2
sudo -u vagrant \
  ORDERS_DB_HOST=$ORDERS_DB_HOST \
  ORDERS_DB_NAME=$ORDERS_DB_NAME \
  ORDERS_DB_USER=$ORDERS_DB_USER \
  ORDERS_DB_PASSWORD=$ORDERS_DB_PASSWORD \
  ORDERS_TABLE=$ORDERS_TABLE \
  BILLING_QUEUE=$BILLING_QUEUE \
  BILLING_PORT=$BILLING_PORT \
  RABBITMQ_HOST=$RABBITMQ_HOST \
  pm2 start consumer.js --name orders-consumer
  
sudo -u vagrant pm2 save