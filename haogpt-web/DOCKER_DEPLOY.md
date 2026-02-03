# Docker Deployment Guide

## 🐳 Simple Docker Deployment

### 1. On Your Local Machine

```bash
# Build the app
npm run build

# Make deploy script executable
chmod +x docker-deploy.sh

# Deploy to EC2 (replace with your details)
./docker-deploy.sh your-ec2-ip ~/.ssh/your-key.pem
```

### 2. Manual Docker Deployment

If you prefer manual steps:

```bash
# Build and package
npm run build
tar -czf docker-package.tar.gz .next public package.json package-lock.json next.config.mjs Dockerfile .dockerignore

# Upload to EC2
scp -i your-key.pem docker-package.tar.gz ec2-user@your-ec2-ip:~/
```

### 3. On Your EC2 Server

```bash
# Extract package
cd ~
tar -xzf docker-package.tar.gz

# Create environment file
cp deployment/production.env.example .env.production
nano .env.production  # Add your actual environment variables

# Build and run with Docker
sudo docker build -t haogpt-web .
sudo docker run -d \
  --name haogpt-web \
  -p 3000:3000 \
  --env-file .env.production \
  --restart unless-stopped \
  haogpt-web
```

### 4. Verify Deployment

```bash
# Check if container is running
sudo docker ps

# View logs
sudo docker logs haogpt-web

# Test the app
curl http://localhost:3000
```

### 5. Useful Docker Commands

```bash
# Restart container
sudo docker restart haogpt-web

# Stop container
sudo docker stop haogpt-web

# View real-time logs
sudo docker logs -f haogpt-web

# Access container shell
sudo docker exec -it haogpt-web sh

# Remove container and image (for fresh deployment)
sudo docker stop haogpt-web
sudo docker rm haogpt-web
sudo docker rmi haogpt-web
```

## 🌐 Access Your App

Visit: `http://your-ec2-ip:3000`

## 🔧 Environment Variables

Make sure to set these in `.env.production`:

```bash
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
OPENAI_API_KEY=your_openai_api_key
GOOGLE_API_KEY=your_google_api_key
GOOGLE_CSE_ID=your_google_cse_id
NEXTAUTH_URL=http://your-ec2-ip:3000
NEXTAUTH_SECRET=your_secret_key
NODE_ENV=production
```

That's it! 🚀
