#!/bin/bash

# EC2 Server Setup Script for HaoGPT Web App
# Run this on your EC2 instance

set -e

echo "🔧 Setting up EC2 server for HaoGPT Web App..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Node.js 20 LTS
echo "📦 Installing Node.js 20 LTS..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
echo "📦 Installing PM2 process manager..."
sudo npm install -g pm2

# Install Nginx
echo "📦 Installing Nginx..."
sudo apt install -y nginx

# Create app directory
echo "📁 Creating application directory..."
sudo mkdir -p /var/www/haogpt-web
sudo chown -R ubuntu:ubuntu /var/www/haogpt-web

# Configure Nginx
echo "🔧 Configuring Nginx..."
sudo tee /etc/nginx/sites-available/haogpt-web > /dev/null << 'EOF'
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Enable Nginx site
sudo ln -sf /etc/nginx/sites-available/haogpt-web /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Setup PM2 startup
echo "🚀 Setting up PM2 startup..."
pm2 startup
# Note: Follow the instructions that PM2 prints

echo "✅ Server setup completed!"
echo ""
echo "Next steps:"
echo "1. Copy your environment variables to /var/www/haogpt-web/.env.production"
echo "2. Update the Nginx configuration with your actual domain"
echo "3. Run the deployment script from your local machine"
echo "4. Setup SSL with Let's Encrypt (optional but recommended)"
