# WebSocket Server - Cloud VM Deployment Guide

## Quick Start

### Option 1: Docker Deployment (Recommended)

1. **Copy files to your VM:**
   ```bash
   scp -r ./src/socket user@your-vm-ip:/home/user/websocket-server
   ```

2. **SSH into your VM:**
   ```bash
   ssh user@your-vm-ip
   cd websocket-server
   ```

3. **Run the deployment script:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh 5000  # Or your preferred port
   ```

### Option 2: Docker Compose

```bash
docker-compose up -d
```

### Option 3: Direct Deployment (No Docker)

```bash
chmod +x deploy-without-docker.sh
sudo ./deploy-without-docker.sh 5000
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `5000` | Port the server listens on |
| `ALLOWED_ORIGINS` | `*` | Comma-separated list of allowed CORS origins |
| `ASPNETCORE_ENVIRONMENT` | `Production` | .NET environment |

### Examples

**Restrict CORS to specific domains:**
```bash
docker run -d \
    -p 5000:5000 \
    -e ALLOWED_ORIGINS="https://myapp.com,https://api.myapp.com" \
    websocket-server
```

---

## Firewall Configuration

### Ubuntu/Debian (UFW)
```bash
sudo ufw allow 5000/tcp
sudo ufw reload
```

### CentOS/RHEL (firewalld)
```bash
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

### Cloud Provider Security Groups
- **AWS**: Add inbound rule for TCP port 5000
- **Azure**: Add inbound security rule for port 5000
- **GCP**: Create firewall rule allowing TCP:5000

---

## Nginx Reverse Proxy (Optional)

For production, use Nginx as a reverse proxy with SSL:

```nginx
# /etc/nginx/sites-available/websocket
server {
    listen 80;
    server_name your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }
    
    location /health {
        proxy_pass http://127.0.0.1:5000/health;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/websocket /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## SSL with Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Server status (JSON) |
| `/health` | GET | Health check for load balancers |
| `/ws` | WebSocket | WebSocket connection endpoint |

---

## Testing

### Test HTTP endpoints:
```bash
# Health check
curl http://YOUR_VM_IP:5000/health

# Server status
curl http://YOUR_VM_IP:5000/
```

### Test WebSocket connection:
```bash
# Using websocat (install: cargo install websocat)
websocat ws://YOUR_VM_IP:5000/ws

# Or using wscat (install: npm install -g wscat)
wscat -c ws://YOUR_VM_IP:5000/ws
```

---

## Monitoring

### View logs (Docker):
```bash
docker logs -f websocket-server
```

### View logs (systemd):
```bash
sudo journalctl -u websocket-server -f
```

### Check container status:
```bash
docker ps
docker stats websocket-server
```

---

## Troubleshooting

### Container won't start
```bash
docker logs websocket-server
```

### Port already in use
```bash
sudo lsof -i :5000
sudo kill -9 <PID>
```

### Permission denied
```bash
sudo chmod +x deploy.sh
```

### Connection refused
1. Check if the service is running
2. Verify firewall rules
3. Check cloud security groups
