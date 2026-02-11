#!/bin/bash
# ------------------------------------------------------------------------------
# Docker CE Installer for Ubuntu
# ------------------------------------------------------------------------------
# Copyright (C) 2025 Gary Leong <gary@config0.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# ------------------------------------------------------------------------------
# This script installs Docker CE on Ubuntu systems.
# It follows the official Docker installation process:
# 1. Sets up prerequisites
# 2. Adds Docker's official GPG key
# 3. Verifies the key fingerprint
# 4. Sets up the stable repository
# 5. Updates package lists and installs Docker CE
#
# The script references the Docker repository at:
# https://download.docker.com/linux/ubuntu/
# ------------------------------------------------------------------------------

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo privileges."
    exit 1
fi

# Function for error handling
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

echo "Starting Docker CE installation for Ubuntu..."

# Update package lists
echo "Updating package lists..."
apt-get update -y || error_exit "Failed to update package lists"

# Install prerequisites
echo "Installing prerequisites..."
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y || error_exit "Failed to install prerequisites"

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - || \
    error_exit "Failed to add Docker's GPG key"

# Verify fingerprint
echo "Verifying key fingerprint..."
apt-key fingerprint 0EBFCD88 || error_exit "Failed to verify key fingerprint"

# Set up the stable repository
echo "Setting up Docker repository..."
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" || error_exit "Failed to add Docker repository"

# Update package lists again with new repository
echo "Updating package lists with Docker repository..."
apt-get update || error_exit "Failed to update package lists"

# Install Docker CE
echo "Installing Docker CE..."
apt-get install docker-ce -y || error_exit "Failed to install Docker CE"

# Verify Docker installation
echo "Verifying Docker installation..."
if command -v docker &> /dev/null; then
    echo "Docker CE installation complete!"
    echo "Docker version: $(docker --version)"
else
    error_exit "Docker installation verification failed"
fi