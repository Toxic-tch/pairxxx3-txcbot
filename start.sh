#!/bin/bash

echo "=== Starting Pterodactyl Wings ==="

# Start Docker daemon
echo "Starting Docker daemon..."
dockerd --iptables=false --ip6tables=false &>/tmp/dockerd.log &
sleep 5

# Check Docker is running
if docker info &>/dev/null; then
    echo "Docker started successfully!"
else
    echo "Docker failed to start, logs:"
    cat /tmp/dockerd.log
    echo "Starting Wings anyway (Docker features won't work)..."
fi

# Start Wings
echo "Starting Wings..."
cd /etc/pterodactyl
exec wings
