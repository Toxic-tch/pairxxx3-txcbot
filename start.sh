#!/bin/bash

echo "======================================="
echo "  VPS Starting..."
echo "======================================="

# ============================================
# 1. Start SSH Server
# ============================================
echo "[1/5] Starting SSH server..."
/usr/sbin/sshd
echo "  SSH running on port 22 (root/root)"

# ============================================
# 2. Start Docker
# ============================================
echo "[2/5] Starting Docker daemon..."
rm -f /var/run/docker.pid /var/run/docker.sock

(dockerd \
    --iptables=false \
    --ip6tables=false \
    --bridge=none \
    --storage-driver=vfs \
    &>/var/log/dockerd.log &)

DOCKER_READY=0
for i in $(seq 1 30); do
    if docker info >/dev/null 2>&1; then
        DOCKER_READY=1
        echo "  Docker is ready!"
        break
    fi
    sleep 2
done

if [ "$DOCKER_READY" = "0" ]; then
    echo "  WARNING: Docker failed to start"
    echo "  Log:"
    tail -5 /var/log/dockerd.log
else
    echo "  Docker version: $(docker --version)"
fi

# ============================================
# 3. Start Wings
# ============================================
echo "[3/5] Starting Wings..."
export TZ=UTC

# Fix port in config to 8080
sed -i 's/port: 443/port: 8080/' /etc/pterodactyl/config.yml 2>/dev/null
sed -i 's/port: 443/port: 8080/' /etc/pterodactyl/config.yml 2>/dev/null

(/usr/local/bin/wings &>/var/log/wings.log &)
sleep 3

if curl -s http://localhost:8080 >/dev/null 2>&1; then
    echo "  Wings is running on port 8080!"
else
    echo "  WARNING: Wings may not be running"
    tail -3 /var/log/wings.log
fi

# ============================================
# 4. Start Cloudflare Tunnel
# ============================================
echo "[4/5] Starting Cloudflare Tunnel..."
(/usr/local/bin/cloudflared tunnel --url http://localhost:8080 &>/var/log/cloudflared.log &)
sleep 3

TUNNEL_URL=$(grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' /var/log/cloudflared.log 2>/dev/null | head -1)
if [ -n "$TUNNEL_URL" ]; then
    echo "  Tunnel URL: $TUNNEL_URL"
    echo "  >>> Use this URL as your Node FQDN in Pterodactyl Panel"
else
    echo "  Tunnel starting... (URL will appear in Wings log)"
fi

# ============================================
# 5. Start Shellinabox (Web Terminal)
# ============================================
echo "[5/5] Starting Web Terminal..."

# Use Render's PORT or default 4200
WEB_PORT="${PORT:-4200}"

/usr/bin/shellinaboxd \
    -t \
    -s "/:LOGIN" \
    --listen 0.0.0.0:$WEB_PORT \
    --disable-ssl \
    --service "/:root:root:/:bash"

echo ""
echo "======================================="
echo "  VPS READY!"
echo "======================================="
echo "  Web Terminal: http://localhost:$WEB_PORT"
echo "  SSH: port 22 (root/root)"
echo "  Wings API: port 8080"
echo "  SFTP: port 2022"
echo "======================================="

# Keep container alive
while true; do
    # Show tunnel URL every 30 seconds
    NEW_URL=$(grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' /var/log/cloudflared.log 2>/dev/null | tail -1)
    if [ -n "$NEW_URL" ] && [ "$NEW_URL" != "$TUNNEL_URL" ]; then
        TUNNEL_URL=$NEW_URL
        echo ">>> NEW Tunnel URL: $TUNNEL_URL"
        echo ">>> Use this as Node FQDN in Pterodactyl Panel"
    fi
    sleep 30
done
