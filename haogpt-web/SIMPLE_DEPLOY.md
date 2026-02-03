# Simple EC2 Deployment for Testing

## 1. On Your Local Machine

```bash
# Build the app
npm run build

# Create a simple package
tar -czf haogpt-web.tar.gz .next public package.json package-lock.json next.config.mjs
```

## 2. On Your EC2 Server

```bash
# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create app directory
mkdir ~/haogpt-web
cd ~/haogpt-web
```

## 3. Upload and Run

```bash
# Upload your package (from local machine)
scp -i your-key.pem haogpt-web.tar.gz ubuntu@your-ec2-ip:~/haogpt-web/

# On EC2: Extract and run
cd ~/haogpt-web
tar -xzf haogpt-web.tar.gz
npm ci --only=production

# Create environment file
nano .env.production
# Copy your environment variables here

# Start the app
npm start
```

## 4. Access Your App

Open your browser: `http://your-ec2-ip:3000`

That's it! 🚀
