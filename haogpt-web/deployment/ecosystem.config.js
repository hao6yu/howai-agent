module.exports = {
  apps: [
    {
      name: 'haogpt-web',
      script: 'npm',
      args: 'start',
      cwd: '/var/www/haogpt-web',
      instances: 'max', // Use all CPU cores
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: '/var/log/pm2/haogpt-web-error.log',
      out_file: '/var/log/pm2/haogpt-web-out.log',
      log_file: '/var/log/pm2/haogpt-web-combined.log',
      time: true,
      max_memory_restart: '1G',
      node_args: '--max-old-space-size=1024',
      watch: false,
      ignore_watch: [
        'node_modules',
        '.next',
        'logs'
      ],
      restart_delay: 4000,
      max_restarts: 10,
      min_uptime: '10s'
    }
  ]
}
