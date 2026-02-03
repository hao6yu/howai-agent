#!/bin/bash

# HaoGPT Web App Deployment Script
# Usage: ./deploy.sh [server-ip] [ssh-key-path]

set -e

SERVER_IP=${1:-"your-ec2-ip"}
SSH_KEY=${2:-"~/.ssh/your-key.pem"}
APP_NAME="haogpt-web"
REMOTE_DIR="/var/www/$APP_NAME"
LOCAL_DIR="$(pwd)"

echo "🚀 Starting deployment to $SERVER_IP..."

# Build the application locally
echo "📦 Building application..."
npm run build

# Create deployment package
echo "📁 Creating deployment package..."
tar -czf deployment-package.tar.gz \
  .next \
  public \
  package.json \
  package-lock.json \
  next.config.mjs \
  deployment/

# Upload to server
echo "⬆️  Uploading to server..."
scp -i "$SSH_KEY" deployment-package.tar.gz ubuntu@$SERVER_IP:/tmp/

# Deploy on server
echo "🔧 Deploying on server..."
ssh -i "$SSH_KEY" ubuntu@$SERVER_IP << 'EOF'
  set -e
  
  # Create app directory
  sudo mkdir -p /var/www/haogpt-web
  cd /var/www/haogpt-web
  
  # Backup current deployment
  if [ -d ".next" ]; then
    sudo mv .next .next.backup.$(date +%Y%m%d_%H%M%S)
  fi
  
  # Extract new deployment
  sudo tar -xzf /tmp/deployment-package.tar.gz
  sudo chown -R ubuntu:ubuntu /var/www/haogpt-web
  
  # Install dependencies
  npm ci --only=production
  
  # Restart application
  pm2 restart haogpt-web || pm2 start npm --name "haogpt-web" -- start
  
  # Cleanup
  rm /tmp/deployment-package.tar.gz
  
  echo "✅ Deployment completed successfully!"
EOF

# Cleanup local files
rm deployment-package.tar.gz

echo "🎉 Deployment finished! Your app should be running at http://$SERVER_IP:3000"
