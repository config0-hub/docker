#!/bin/bash
# ------------------------------------------------------------------------------
# Docker Image Builder with Custom Dockerfile
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
# This script builds a Docker image using a specified Dockerfile and tags it
# with a repository URI and image tag.
#
# The script provides default values for all parameters but allows them to be
# overridden through environment variables.
#
# Usage: 
#   ./script.sh
#   or with custom settings:
#   REPOSITORY_URI="myrepo" DOCKER_IMAGE_TAG="1.0" DOCKER_FILE="Dockerfile.prod" ./script.sh
#
# Environment variables:
#   - DOCKER_BUILD_DIR: Directory containing Dockerfile (default: /var/tmp/docker/build)
#   - DOCKER_ENV_FILE: Path to environment file (default: $DOCKER_BUILD_DIR/.env)
#   - DOCKER_FILE: Name of the Dockerfile to use (default: Dockerfile)
#   - DOCKER_IMAGE_TAG: Tag for the Docker image (default: test)
#   - REPOSITORY_URI: Repository URI or image name (default: test)
# ------------------------------------------------------------------------------

# Set default values if environment variables aren't provided
export DOCKER_BUILD_DIR=${DOCKER_BUILD_DIR:=/var/tmp/docker/build}
export DOCKER_ENV_FILE=${DOCKER_ENV_FILE:="${DOCKER_BUILD_DIR}/.env"}
export DOCKER_FILE=${DOCKER_FILE:=Dockerfile}
export DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG:=test}
export REPOSITORY_URI=${REPOSITORY_URI:=test}

# Navigate to build directory
cd "$DOCKER_BUILD_DIR" || exit 1

# Build Docker image
echo "Building Docker image..."
echo "Repository: $REPOSITORY_URI"
echo "Tag: $DOCKER_IMAGE_TAG"
echo "Dockerfile: $DOCKER_FILE"
echo "Build directory: $DOCKER_BUILD_DIR"

docker build -t "$REPOSITORY_URI:$DOCKER_IMAGE_TAG" . -f "$DOCKER_FILE" || exit 1

echo "Docker image build successful: $REPOSITORY_URI:$DOCKER_IMAGE_TAG"