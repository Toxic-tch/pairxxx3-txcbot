FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=4200

# ============================================
# Install ALL packages
# ============================================
RUN apt-get update && apt-get install -y \
    openssh-server \
    shellinabox \
    sudo \
    curl \
    wget \
    git \
    nano \
    vim \
    htop \
    tmux \
    screen \
    net-tools \
    iproute2 \
    iptables \
    ip6tables \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    tar \
    jq \
    tree \
    procps \
    psmisc \
    software-properties-common \
    python3 \
    python3-pip \
    rsync \
    telnet \
    netcat \
    traceroute \
    dnsutils \
    whois \
    finger \
    less \
    man-db \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Install Docker
# ============================================
RUN curl -fsSL https://get.docker.com -o /tmp/get-docker.sh && \
    sh /tmp/get-docker.sh && \
    rm /tmp/get-docker.sh

# ============================================
# Install Cloudflare Tunnel (for Wings)
# ============================================
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# ============================================
# Install Wings v1.11.10
# ============================================
RUN mkdir -p /etc/pterodactyl \
    /var/lib/pterodactyl/volumes \
    /var/lib/pterodactyl/archives \
    /var/lib/pterodactyl/backups \
    /var/log/pterodactyl \
    /tmp/pterodactyl

RUN curl -fsSL -o /usr/local/bin/wings \
    "https://github.com/pterodactyl/wings/releases/download/v1.11.10/wings_linux_amd64" && \
    chmod +x /usr/local/bin/wings

# ============================================
# SSH Setup
# ============================================
RUN mkdir -p /var/run/sshd
RUN echo "root:root" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ============================================
# Shellinabox Setup (Web Terminal)
# ============================================
RUN sed -i 's/SHELLINABOX_PORT=4200/SHELLINABOX_PORT=0.0.0.0:4200/' /etc/default/shellinabox

# ============================================
# Copy Wings config and start script
# ============================================
COPY config.yml /etc/pterodactyl/config.yml
COPY start.sh /start.sh
RUN chmod +x /start.sh

# ============================================
# Expose ports
# ============================================
EXPOSE 4200 22 8080 2022 25565

# ============================================
# Start everything
# ============================================
CMD ["/start.sh"]
