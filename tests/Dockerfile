FROM debian:stable-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    stow \
    curl \
    git \
    ca-certificates \
    gpg \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install go-task
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Install sops
RUN curl -L https://github.com/getsops/sops/releases/download/v3.13.0/sops-v3.13.0.linux.amd64 -o /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops

# Create test user
RUN useradd -m -s /bin/bash testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Pre-create config directories to prevent Docker from creating them as root
RUN mkdir -p /home/testuser/.config/sops/age \
    && chown -R testuser:testuser /home/testuser/.config

USER testuser
WORKDIR /home/testuser/dotfiles
