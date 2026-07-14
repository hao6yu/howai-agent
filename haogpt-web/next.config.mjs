/** @type {import('next').NextConfig} */
const nextConfig = {
  outputFileTracingRoot: new URL('.', import.meta.url).pathname,
  // Increase API route timeouts for image generation and AI responses
  serverExternalPackages: ['openai'],
};

export default nextConfig;
