FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Docker and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    iptables \
    kmod \
    git \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Docker (Docker-in-Docker)
RUN curl -fsSL https://get.docker.com | sh

# Install Wings
RUN curl -L -o /usr/local/bin/wings \
    https://github.com/pterodactyl/wings/releases/download/v1.11.10/wings_linux_amd64 \
    && chmod +x /usr/local/bin/wings

# Create directories
RUN mkdir -p /etc/pterodactyl \
    /var/lib/pterodactyl/volumes \
    /var/lib/pterodactyl/archives \
    /var/lib/pterodactyl/backups \
    /var/log/pterodactyl \
    /tmp/pterodactyl

# Set timezone
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy config and start script
COPY config.yml /etc/pterodactyl/config.yml
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080 2022

CMD ["/start.sh"]
