FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# ── Core packages ────────────────────────────────────────────────
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    sudo bash curl wget git vim nano htop neofetch \
    procps lsof tmux screen \
    net-tools iputils-ping dnsutils iproute2 netcat-openbsd nmap traceroute \
    build-essential gcc g++ make cmake pkg-config \
    python3 python3-pip python3-venv \
    zip unzip tar gzip bzip2 xz-utils \
    tree ncdu mc \
    nginx supervisor \
    openssh-client openssh-server \
    software-properties-common ca-certificates gnupg \
    jq bc locales openssl cron man-db \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# ── Node.js 20 ──────────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm i -g yarn pm2 nodemon && \
    rm -rf /var/lib/apt/lists/*

# ── Go 1.22 ─────────────────────────────────────────────────────
RUN wget -qO- https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="${PATH}:/usr/local/go/bin"

# ── ttyd (web terminal) ─────────────────────────────────────────
RUN wget -qO /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# ── File Browser ────────────────────────────────────────────────
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# ── cloudflared (optional tunneling) ────────────────────────────
RUN wget -qO /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

# ── Directories ─────────────────────────────────────────────────
RUN mkdir -p /var/log/supervisor /run/nginx /var/www/dashboard /app

# ── Copy project files ──────────────────────────────────────────
COPY start.sh   /app/start.sh
COPY nginx.conf /app/nginx.conf.template
COPY index.html /var/www/dashboard/index.html
RUN chmod +x /app/start.sh

EXPOSE 10000
CMD ["/app/start.sh"]
