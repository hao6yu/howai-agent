#!/bin/bash

# Docker Deployment Script for EC2
# Usage: ./docker-deploy.sh [server-ip] [ssh-key-path]

set -e

SERVER_IP=${1:-"your-ec2-ip"}
SSH_KEY=${2:-"~/.ssh/your-key.pem"}
IMAGE_NAME="haogpt-web"
CONTAINER_NAME="haogpt-web"

echo "🐳 Starting Docker deployment to $SERVER_IP..."

# Build the application locally
echo "📦 Building application..."
npm run build

# Create deployment package including Docker files
echo "📁 Creating deployment package..."
tar -czf docker-package.tar.gz \
  .next \
  public \
  package.json \
  package-lock.json \
  next.config.mjs \
  Dockerfile \
  .dockerignore \
  deployment/production.env.example

# Upload to server
echo "⬆️  Uploading to server..."
scp -i "$SSH_KEY" docker-package.tar.gz ec2-user@$SERVER_IP:/tmp/

# Deploy on server
echo "🔧 Deploying with Docker on server..."
ssh -i "$SSH_KEY" ec2-user@$SERVER_IP << EOF
  set -e
  
  # Create app directory
  mkdir -p ~/haogpt-web
  cd ~/haogpt-web
  
  # Extract deployment package
  tar -xzf /tmp/docker-package.tar.gz
  
  # Stop and remove existing container
  sudo docker stop $CONTAINER_NAME 2>/dev/null || true
  sudo docker rm $CONTAINER_NAME 2>/dev/null || true
  
  # Build new Docker image
  sudo docker build -t $IMAGE_NAME .
  
  # Run new container
  sudo docker run -d \
    --name $CONTAINER_NAME \
    -p 3000:3000 \
    --env-file .env.production \
    --restart unless-stopped \
    $IMAGE_NAME
  
  # Cleanup
  rm /tmp/docker-package.tar.gz
  
  echo "✅ Docker deployment completed!"
  echo "🐳 Container status:"
  sudo docker ps | grep $CONTAINER_NAME
EOF

echo "🎉 Deployment finished! Your app should be running at http://$SERVER_IP:3000"
echo "📋 Useful commands:"
echo "  View logs: ssh -i $SSH_KEY ec2-user@$SERVER_IP 'sudo docker logs $CONTAINER_NAME'"
echo "  Restart:   ssh -i $SSH_KEY ec2-user@$SERVER_IP 'sudo docker restart $CONTAINER_NAME'"
