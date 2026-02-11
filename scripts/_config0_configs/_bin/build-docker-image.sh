#!/bin/bash
# ------------------------------------------------------------------------------
# Docker Image Builder
# ------------------------------------------------------------------------------
# This script builds Docker images with proper tagging.
#
# Copyright 2025 Gary Leong <gary@config0.com>
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
# This script handles:
# - Setting up the environment file for the Dockerfile
# - Parsing image information from DOCKER_IMAGE if DOCKER_REPO isn't provided
# - Building the image with both specific tag and 'latest' tag
#
# Required environment variables:
#   - Either DOCKER_REPO or DOCKER_IMAGE must be set
#
# Optional environment variables:
#   - DOCKER_BUILD_DIR: Directory containing Dockerfile (default: /var/tmp/docker/build)
#   - DOCKER_ENV_FILE: Environment file to be copied into container (default: $DOCKER_BUILD_DIR/.env)
# ------------------------------------------------------------------------------

# Set default values for build directory and environment file
export DOCKER_BUILD_DIR=${DOCKER_BUILD_DIR:=/var/tmp/docker/build}
export DOCKER_ENV_FILE=${DOCKER_ENV_FILE:=${DOCKER_BUILD_DIR}/.env}

# Handle environment file for Docker build
if [ -f "$DOCKER_ENV_FILE" ]; then
    echo "DOCKER_ENV_FILE $DOCKER_ENV_FILE found."
    if [ "$DOCKER_ENV_FILE" != "$DOCKER_BUILD_DIR/.env" ]; then
        cp -rp "$DOCKER_ENV_FILE" "$DOCKER_BUILD_DIR/.env" || exit 1
    fi
else
    echo ""
    echo "WARNING: $DOCKER_ENV_FILE not found."
    echo ""
fi

# If DOCKER_REPO is not set, try to extract it from DOCKER_IMAGE
if [ -z "${DOCKER_REPO+x}" ]; then
    echo "DOCKER_REPO is unset, attempting to extract from DOCKER_IMAGE..."

    export DOCKER_IMAGE=$(echo "$DOCKER_IMAGE" | sed -e 's/ //g')
    export DOCKER_REPO_TAG=$(echo "$DOCKER_IMAGE" | cut -d ":" -f 2)
    export REPO_NAME=$(echo "$DOCKER_IMAGE" | cut -d ":" -f 1)

    export DOCKER_REGISTRY=$(echo "$REPO_NAME" | cut -d "/" -f 1)
    export USERNAME=$(echo "$REPO_NAME" | cut -d "/" -f 2)
    export DOCKER_REPO=$(echo "$REPO_NAME" | cut -d "/" -f 3)
fi

# Validate that DOCKER_REPO is now set
if [ -z "${DOCKER_REPO+x}" ]; then
    echo ""
    echo "ERROR: DOCKER_REPO (e.g. flask_sample) needs to be set to do a build"
    echo ""
    exit 1
fi

# Build Docker image with specific tag if provided
if [ ! -z "${DOCKER_REPO_TAG+x}" ]; then
    echo "Building Docker image: $DOCKER_REPO with tag: $DOCKER_REPO_TAG"
    cd "$DOCKER_BUILD_DIR" || exit 1
    docker build -t "$DOCKER_REPO:$DOCKER_REPO_TAG" . || exit 1
fi

# Always build with 'latest' tag
echo "Building Docker image: $DOCKER_REPO with tag: latest"
cd "$DOCKER_BUILD_DIR" || exit 1
docker build -t "$DOCKER_REPO" . || exit 1

echo ""
echo "Build complete!"