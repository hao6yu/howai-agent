#!/bin/bash

# Docker Registry Deployment Script
# Usage: ./docker-registry-deploy.sh [docker-username] [server-ip] [ssh-key-path]

set -e

DOCKER_USERNAME=${1:-"your-docker-username"}
SERVER_IP=${2:-"your-ec2-ip"}
SSH_KEY=${3:-"~/.ssh/your-key.pem"}
IMAGE_NAME="$DOCKER_USERNAME/haogpt-web"
TAG="latest"

echo "🐳 Building and pushing Docker image..."

# Note: With the new multi-stage Dockerfile, we don't need to build locally
# The Docker build process will handle the Next.js build inside the container

# Build Docker image locally (reads from .env.local automatically)
echo "🔨 Building Docker image: $IMAGE_NAME:$TAG"
docker build -t $IMAGE_NAME:$TAG .

# Push to Docker Hub
echo "⬆️  Pushing to Docker Hub..."
docker push $IMAGE_NAME:$TAG

# Deploy on EC2 server
echo "🚀 Deploying on EC2 server..."
ssh -i "$SSH_KEY" ec2-user@$SERVER_IP << EOF
  set -e
  
  echo "📥 Pulling Docker image from registry..."
  sudo docker pull $IMAGE_NAME:$TAG
  
  echo "🛑 Stopping existing container..."
  sudo docker stop haogpt-web 2>/dev/null || true
  sudo docker rm haogpt-web 2>/dev/null || true
  
  echo "🚀 Starting new container..."
  sudo docker run -d \
    --name haogpt-web \
    -p 3000:3000 \
    --env-file ~/.env.production \
    --restart unless-stopped \
    $IMAGE_NAME:$TAG
  
  echo "✅ Deployment completed!"
  echo "🐳 Container status:"
  sudo docker ps | grep haogpt-web
EOF

echo "🎉 Deployment finished!"
echo "📋 Your app should be running at http://$SERVER_IP:3000"
echo ""
echo "Useful commands:"
echo "  View logs: ssh -i $SSH_KEY ec2-user@$SERVER_IP 'sudo docker logs haogpt-web'"
echo "  Restart:   ssh -i $SSH_KEY ec2-user@$SERVER_IP 'sudo docker restart haogpt-web'"
