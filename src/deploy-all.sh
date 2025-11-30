#!/bin/bash
# eUIT Full Stack Deployment Script
# Usage: ./deploy-all.sh

set -e

echo "=========================================="
echo "  eUIT Full Stack Cloud Deployment"
echo "=========================================="

# Check if .env exists
if [ ! -f .env ]; then
    echo ""
    echo "ERROR: .env file not found!"
    echo "Please copy .env.example to .env and configure it:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    exit 1
fi

# Load environment variables
source .env

# Check required variables
if [ -z "$GOOGLE_API_KEY" ] || [ "$GOOGLE_API_KEY" = "your_google_api_key_here" ]; then
    echo ""
    echo "ERROR: GOOGLE_API_KEY is not configured in .env"
    exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "your_secure_password_here" ]; then
    echo ""
    echo "ERROR: POSTGRES_PASSWORD is not configured in .env"
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed. Please log out and back in, then run this script again."
    exit 0
fi

# Check docker compose
if ! docker compose version &> /dev/null; then
    echo "Docker Compose not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
fi

echo ""
echo "1. Stopping existing containers..."
docker compose down 2>/dev/null || true

echo ""
echo "2. Building all services..."
docker compose build --no-cache

echo ""
echo "3. Starting all services..."
docker compose up -d

echo ""
echo "4. Waiting for services to be ready..."
sleep 10

echo ""
echo "5. Checking service status..."
docker compose ps

echo ""
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
echo "Services running:"
echo "  - Backend API:    http://YOUR_VM_IP:8080"
echo "  - Swagger UI:     http://YOUR_VM_IP:8080/swagger"
echo "  - Chatbot API:    http://YOUR_VM_IP:5001"
echo "  - WebSocket:      ws://YOUR_VM_IP:5000/ws"
echo "  - PostgreSQL:     YOUR_VM_IP:5432"
echo ""
echo "Useful commands:"
echo "  - View logs:        docker compose logs -f"
echo "  - View backend:     docker compose logs -f backend"
echo "  - View chatbot:     docker compose logs -f chatbot"
echo "  - Stop all:         docker compose down"
echo "  - Restart all:      docker compose restart"
echo ""
