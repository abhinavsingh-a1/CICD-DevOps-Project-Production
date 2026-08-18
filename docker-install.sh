#!/bin/bash

# Stop when something fails
set -e

echo "===== Docker Installation Script ====="

# Remove old Docker-related packages
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1) -y || true

# Add Docker's official GPG key:
# Update APT package information
sudo apt update
# Install prerequisites
sudo apt install -y ca-certificates curl
# Create the APT keyring directory
sudo install -m 0755 -d /etc/apt/keyrings
# Download Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# Change key permissions
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources:
# tee can receive input and write it to a file.
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group
sudo usermod -aG docker $USER

echo ""
echo "===== Docker Installation Complete ====="
echo "👉 Verify: docker --version"
