FROM debian:stable-slim

ARG ENSTOW_VERSION=0.1.16

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gpg \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install go-task
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Install enstow static binary
RUN ARCH="$(uname -m)" \
    && curl -fsSL "https://github.com/nicholaswilde/enstow/releases/download/v${ENSTOW_VERSION}/enstow-${ENSTOW_VERSION}-${ARCH}-unknown-linux-musl.tar.gz" \
       | tar -xz --strip-components=1 -C /usr/local/bin "enstow-${ENSTOW_VERSION}-${ARCH}-unknown-linux-musl/enstow" \
    && chmod +x /usr/local/bin/enstow

# Create test user
RUN useradd -m -s /bin/bash testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Pre-create config directories to prevent Docker from creating them as root
RUN mkdir -p /home/testuser/.config/sops/age \
    && chown -R testuser:testuser /home/testuser/.config

USER testuser
WORKDIR /home/testuser/dotfiles
