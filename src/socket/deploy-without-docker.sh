#!/bin/bash
# WebSocket Server Deployment Script (without Docker)
# For Ubuntu/Debian VMs
# Usage: ./deploy-without-docker.sh [port]

set -e

PORT=${1:-5000}
APP_DIR="/opt/websocket-server"
SERVICE_NAME="websocket-server"

echo "=========================================="
echo "  WebSocket Server Direct Deployment"
echo "=========================================="

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo: sudo ./deploy-without-docker.sh"
    exit 1
fi

# Install .NET 9 Runtime if not present
if ! command -v dotnet &> /dev/null; then
    echo "Installing .NET 9 Runtime..."
    
    # Add Microsoft package repository
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    
    apt-get update
    apt-get install -y aspnetcore-runtime-9.0
fi

echo ""
echo "1. Creating application directory..."
mkdir -p $APP_DIR

echo ""
echo "2. Publishing application..."
dotnet publish -c Release -o $APP_DIR

echo ""
echo "3. Creating systemd service..."
cat > /etc/systemd/system/$SERVICE_NAME.service << EOF
[Unit]
Description=WebSocket Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/dotnet $APP_DIR/socket.dll
Restart=always
RestartSec=10
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=PORT=$PORT
Environment=ALLOWED_ORIGINS=*

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "4. Setting permissions..."
chown -R www-data:www-data $APP_DIR

echo ""
echo "5. Starting service..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl restart $SERVICE_NAME

echo ""
echo "6. Checking service status..."
systemctl status $SERVICE_NAME --no-pager

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
echo ""
echo "Useful commands:"
echo "  - View logs:    sudo journalctl -u $SERVICE_NAME -f"
echo "  - Stop server:  sudo systemctl stop $SERVICE_NAME"
echo "  - Restart:      sudo systemctl restart $SERVICE_NAME"
echo "  - Status:       sudo systemctl status $SERVICE_NAME"
echo ""
