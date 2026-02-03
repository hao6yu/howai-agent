#!/bin/bash

# SSL Setup Script using Let's Encrypt
# Run this on your EC2 instance after domain is pointing to your server

set -e

DOMAIN=${1:-"your-domain.com"}
EMAIL=${2:-"your-email@example.com"}

echo "🔒 Setting up SSL for $DOMAIN..."

# Install Certbot
echo "📦 Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
echo "🔐 Obtaining SSL certificate..."
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --email $EMAIL --agree-tos --non-interactive

# Setup auto-renewal
echo "🔄 Setting up auto-renewal..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test renewal
echo "🧪 Testing renewal..."
sudo certbot renew --dry-run

echo "✅ SSL setup completed!"
echo "Your site should now be accessible at https://$DOMAIN"
