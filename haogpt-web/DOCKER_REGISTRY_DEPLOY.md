# Docker Registry Deployment Guide

## 🐳 Deploy via Docker Hub (Recommended)

This method builds the image locally and pushes it to Docker Hub, then pulls it on your EC2 server.

### Prerequisites

1. **Docker Hub account** (free): https://hub.docker.com/
2. **Docker installed locally** on your development machine
3. **Logged into Docker Hub** locally

### Setup (One-time)

```bash
# 1. Login to Docker Hub locally
docker login
# Enter your Docker Hub username and password

# 2. Create environment file on EC2 server
scp -i your-key.pem deployment/production.env.example ec2-user@your-ec2-ip:~/.env.production
ssh -i your-key.pem ec2-user@your-ec2-ip
nano ~/.env.production  # Add your actual environment variables
exit
```

### Deployment Steps

#### Method 1: Automated Script

```bash
# Make script executable
chmod +x docker-registry-deploy.sh

# Deploy (replace with your details)
./docker-registry-deploy.sh your-docker-username your-ec2-ip ~/.ssh/your-key.pem
```

#### Method 2: Manual Steps

```bash
# 1. Build Next.js app
npm run build

# 2. Build Docker image (replace 'yourusername' with your Docker Hub username)
docker build -t yourusername/haogpt-web:latest .

# 3. Push to Docker Hub
docker push yourusername/haogpt-web:latest

# 4. Deploy on EC2
ssh -i your-key.pem ec2-user@your-ec2-ip << 'EOF'
  # Pull the image
  sudo docker pull yourusername/haogpt-web:latest
  
  # Stop existing container
  sudo docker stop haogpt-web 2>/dev/null || true
  sudo docker rm haogpt-web 2>/dev/null || true
  
  # Run new container
  sudo docker run -d \
    --name haogpt-web \
    -p 3000:3000 \
    --env-file ~/.env.production \
    --restart unless-stopped \
    yourusername/haogpt-web:latest
EOF
```

### Alternative: Private Registry

If you don't want to use Docker Hub (public), you can use:

#### AWS ECR (Amazon Elastic Container Registry)

```bash
# 1. Create ECR repository
aws ecr create-repository --repository-name haogpt-web

# 2. Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# 3. Build and tag
docker build -t haogpt-web .
docker tag haogpt-web:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/haogpt-web:latest

# 4. Push
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/haogpt-web:latest

# 5. Pull on EC2 (with proper IAM role)
sudo docker pull 123456789012.dkr.ecr.us-east-1.amazonaws.com/haogpt-web:latest
```

### Benefits of Registry Approach

✅ **Faster deployments** - no file uploads
✅ **Version control** - tag different versions
✅ **Consistent builds** - same image everywhere
✅ **Easy rollbacks** - pull previous versions
✅ **Smaller bandwidth** - Docker layers are cached

### Useful Commands

```bash
# View your images on Docker Hub
docker search yourusername/haogpt-web

# List local images
docker images

# Remove old local images
docker rmi yourusername/haogpt-web:old-tag

# Check running containers on EC2
ssh -i your-key.pem ec2-user@your-ec2-ip 'sudo docker ps'

# View logs
ssh -i your-key.pem ec2-user@your-ec2-ip 'sudo docker logs haogpt-web'
```

## 🚀 Quick Start

1. **Create Docker Hub account** if you don't have one
2. **Login locally**: `docker login`
3. **Run the script**: `./docker-registry-deploy.sh your-docker-username your-ec2-ip ~/.ssh/your-key.pem`

That's it! 🎉
