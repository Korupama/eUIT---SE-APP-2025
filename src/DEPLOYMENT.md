# eUIT Full Stack - Cloud VM Deployment Guide

## Quick Start

### 1. Copy files to your VM
```bash
scp -r ./src user@your-vm-ip:/home/user/euit-app
```

### 2. SSH into your VM
```bash
ssh user@your-vm-ip
cd euit-app
```

### 3. Configure environment
```bash
cp .env.example .env
nano .env  # Fill in your values
```

### 4. Deploy everything
```bash
chmod +x deploy-all.sh
./deploy-all.sh
```

---

## Services

| Service | Port | Description |
|---------|------|-------------|
| Backend API | 8080 | Main REST API with Swagger |
| Chatbot API | 5001 | AI Chatbot powered by Gemini |
| WebSocket | 5000 | Real-time WebSocket server |
| PostgreSQL | 5432 | Database with pgvector |

---

## Environment Variables

### Required
| Variable | Description |
|----------|-------------|
| `POSTGRES_PASSWORD` | PostgreSQL password |
| `GOOGLE_API_KEY` | Google Gemini API key |

### Optional
| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `postgres` | Database username |
| `POSTGRES_DB` | `eUIT` | Database name |
| `JWT_KEY` | (provided) | JWT signing key |
| `JWT_ISSUER` | `http://localhost:8080` | JWT issuer |
| `JWT_AUDIENCE` | `http://localhost:8080` | JWT audience |
| `FORCE_REINGEST` | `0` | Force re-ingest documents |

---

## Individual Service Deployment

### Backend Only
```bash
cd backend
docker build -t euit-backend .
docker run -d \
    --name euit-backend \
    -p 8080:8080 \
    -e "ConnectionStrings__eUITDatabase=Server=host;Database=eUIT;..." \
    -e "Jwt__Key=your-jwt-key" \
    euit-backend
```

### Chatbot Only
```bash
cd chatbot
docker build -t euit-chatbot .
docker run -d \
    --name euit-chatbot \
    -p 5001:5001 \
    -e GOOGLE_API_KEY=your-api-key \
    -e "AZURE_POSTGRES_URL=Server=host;Database=eUIT;..." \
    -v $(pwd)/pdfs:/app/pdfs:ro \
    -v $(pwd)/docx:/app/docx:ro \
    euit-chatbot
```

### WebSocket Only
```bash
cd socket
docker build -t euit-websocket .
docker run -d \
    --name euit-websocket \
    -p 5000:5000 \
    -e ALLOWED_ORIGINS="*" \
    euit-websocket
```

---

## Firewall Configuration

### Ubuntu (UFW)
```bash
sudo ufw allow 8080/tcp   # Backend
sudo ufw allow 5001/tcp   # Chatbot
sudo ufw allow 5000/tcp   # WebSocket
sudo ufw allow 5432/tcp   # PostgreSQL (optional, for external access)
sudo ufw reload
```

### Cloud Provider Security Groups
Open inbound rules for:
- TCP 8080 (Backend API)
- TCP 5001 (Chatbot API)
- TCP 5000 (WebSocket)
- TCP 5432 (PostgreSQL - if needed)

---

## Nginx Reverse Proxy (Production)

```nginx
# /etc/nginx/sites-available/euit
server {
    listen 80;
    server_name api.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;
    
    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Swagger
    location /swagger {
        proxy_pass http://127.0.0.1:8080/swagger;
        proxy_set_header Host $host;
    }
    
    # Chatbot API
    location /chatbot/ {
        proxy_pass http://127.0.0.1:5001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # WebSocket
    location /ws {
        proxy_pass http://127.0.0.1:5000/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 86400;
    }
}
```

---

## Monitoring & Logs

### View all logs
```bash
docker compose logs -f
```

### View specific service logs
```bash
docker compose logs -f backend
docker compose logs -f chatbot
docker compose logs -f websocket
docker compose logs -f postgres
```

### Check service health
```bash
# Backend
curl http://localhost:8080/swagger/index.html

# Chatbot
curl http://localhost:5001/health

# WebSocket
curl http://localhost:5000/health
```

### Container stats
```bash
docker stats
```

---

## Database Management

### Access PostgreSQL
```bash
docker exec -it euit-postgres psql -U postgres -d eUIT
```

### Backup database
```bash
docker exec euit-postgres pg_dump -U postgres eUIT > backup.sql
```

### Restore database
```bash
cat backup.sql | docker exec -i euit-postgres psql -U postgres -d eUIT
```

---

## Troubleshooting

### Container won't start
```bash
docker compose logs <service-name>
```

### Database connection issues
1. Check if postgres container is healthy: `docker compose ps`
2. Verify connection string format
3. Check if database is initialized

### Chatbot not responding
1. Verify `GOOGLE_API_KEY` is set correctly
2. Check if documents are mounted: `docker exec euit-chatbot ls /app/pdfs`
3. Set `FORCE_REINGEST=1` to re-ingest documents

### Out of memory
```bash
# Increase Docker memory limit or add swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```
