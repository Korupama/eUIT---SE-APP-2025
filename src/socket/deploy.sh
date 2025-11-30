#!/bin/bash
# WebSocket Server Deployment Script for Cloud VM
# Usage: ./deploy.sh [port]

set -e

PORT=${1:-5000}
APP_NAME="websocket-server"

echo "=========================================="
echo "  WebSocket Server Cloud Deployment"
echo "=========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed. Please log out and back in, then run this script again."
    exit 0
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo ""
echo "1. Stopping existing container (if any)..."
docker stop $APP_NAME 2>/dev/null || true
docker rm $APP_NAME 2>/dev/null || true

echo ""
echo "2. Building Docker image..."
docker build -t $APP_NAME .

echo ""
echo "3. Starting container on port $PORT..."
docker run -d \
    --name $APP_NAME \
    --restart unless-stopped \
    -p $PORT:5000 \
    -e PORT=5000 \
    -e ALLOWED_ORIGINS="*" \
    $APP_NAME

echo ""
echo "4. Checking container status..."
sleep 2
docker ps | grep $APP_NAME

echo ""
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
echo "WebSocket server is running on port $PORT"
echo ""
echo "Endpoints:"
echo "  - Health Check: http://YOUR_VM_IP:$PORT/health"
echo "  - WebSocket:    ws://YOUR_VM_IP:$PORT/ws"
echo "  - Status:       http://YOUR_VM_IP:$PORT/"
echo ""
echo "Useful commands:"
echo "  - View logs:    docker logs -f $APP_NAME"
echo "  - Stop server:  docker stop $APP_NAME"
echo "  - Restart:      docker restart $APP_NAME"
echo ""
