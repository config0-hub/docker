#!/bin/bash
# ------------------------------------------------------------------------------
# AWS ECR Docker Image Builder and Pusher
# ------------------------------------------------------------------------------
# This script builds Docker images with proper tagging and pushes them to
# an AWS ECR repository.
#
# It handles:
# - Building the image with both a specific tag and 'latest' tag
# - Logging into the ECR repository
# - Pushing the images to ECR
#
# Usage:
#   REPOSITORY_URI="account.dkr.ecr.region.amazonaws.com/repo-name" \
#   DOCKER_IMAGE_TAG="tag" \
#   ECR_LOGIN="$(aws ecr get-login --no-include-email)" \
#   ./script.sh
#
# Required environment variables:
#   - REPOSITORY_URI: Full ECR repository URI
#   - DOCKER_IMAGE_TAG: Tag for the Docker image
#   - ECR_LOGIN: AWS ECR login command (typically from aws ecr get-login)
#
# Optional environment variables:
#   - DOCKER_BUILD_DIR: Directory containing Dockerfile (default: /var/tmp/docker/build)
#   - DOCKER_ENV_FILE: Environment file path (default: $DOCKER_BUILD_DIR/.env)
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

# Set default values for build directory and environment file
export DOCKER_BUILD_DIR=${DOCKER_BUILD_DIR:=/var/tmp/docker/build}
export DOCKER_ENV_FILE=${DOCKER_ENV_FILE:=${DOCKER_BUILD_DIR}/.env}

echo ""
echo "Building for repository ${REPOSITORY_URI} at ${DOCKER_BUILD_DIR}"
echo ""

# Build with custom image tag
cd "${DOCKER_BUILD_DIR}" || exit 1
echo "Building with tag: ${DOCKER_IMAGE_TAG}"
docker build -t "${REPOSITORY_URI}:${DOCKER_IMAGE_TAG}" . || exit 1

# Build/tag with tag "latest"
echo ""
echo "Building with tag: latest"
docker build -t "${REPOSITORY_URI}:latest" . || exit 1

# Login to ECR repository
echo ""
echo "Logging into ECR repository: ${REPOSITORY_URI}"
${ECR_LOGIN} || exit 1

# Push all tagged images to the repository
echo ""
echo "Pushing images to ECR repository: ${REPOSITORY_URI}"
docker push "${REPOSITORY_URI}" || exit 1

echo ""
echo "Build and push complete!"