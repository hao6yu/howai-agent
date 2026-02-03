# Dockerfile that expects local build
FROM node:20-alpine

WORKDIR /app

# Copy package files and install all dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy the pre-built application
COPY .next ./.next
COPY public ./public
COPY next.config.mjs ./

# Copy environment variables
COPY .env.local ./

# Debug: Verify .next exists
RUN echo "Checking .next folder:" && ls -la .next

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Change ownership of the app directory
RUN chown -R nextjs:nodejs /app
USER nextjs

# Expose port
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production
ENV PORT=3000


# Start the application
CMD ["npm", "start"]
