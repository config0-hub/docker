#!/bin/bash
# ------------------------------------------------------------------------------
# Docker Image Tagger and Pusher
# ------------------------------------------------------------------------------
# This script tags and pushes Docker images to a registry.
# It handles parsing the image name, tagging with both latest and a specific tag,
# and pushing to the specified registry.
#
# Usage:
#   DOCKER_IMAGE="registry/username/repo:tag" ./script.sh
#
# Required environment variables:
#   - DOCKER_IMAGE: Full image name (registry/username/repo:tag)
#   - DOCKER_PASSWORD: Password for registry authentication
#
# Optional environment variables:
#   - DOCKER_USERNAME: Will be extracted from DOCKER_IMAGE if not provided
#
# Optional environment variables:
# Copyright (C) 2025 Gary Leong <gary@config0.com>
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

set -e

# Validate required environment variables
if [ -z "$DOCKER_IMAGE" ]; then
    echo "Error: DOCKER_IMAGE environment variable is required"
    echo "Format: registry/username/repo:tag"
    exit 1
fi

if [ -z "$DOCKER_PASSWORD" ]; then
    echo "Error: DOCKER_PASSWORD environment variable is required"
    exit 1
fi

# Parse and clean image information from DOCKER_IMAGE
export DOCKER_IMAGE=$(echo "$DOCKER_IMAGE" | sed -e 's/ //g')
export REPO_NAME=$(echo "$DOCKER_IMAGE" | cut -d ":" -f 1)
export DOCKER_REPO_TAG=$(echo "$DOCKER_IMAGE" | cut -d ":" -f 2)
export DOCKER_REGISTRY=$(echo "$REPO_NAME" | cut -d "/" -f 1)
export DOCKER_REPO=$(echo "$REPO_NAME" | cut -d "/" -f 3)
export DOCKER_USERNAME=${DOCKER_USERNAME:=$(echo "$REPO_NAME" | cut -d "/" -f 2)}

# Display login information
echo ""
echo "Docker Login Information"
echo "------------------------"
echo "Registry:  $DOCKER_REGISTRY"
echo "Username:  $DOCKER_USERNAME"
echo "Image:     $DOCKER_REPO"
echo "Tag:       $DOCKER_REPO_TAG"
echo ""

# Login to Docker registry
echo "Logging into Docker registry..."
if ! docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD" "https://index.$DOCKER_REGISTRY/v1/"; then
    echo "Error: Failed to log in to Docker registry"
    exit 1
fi

# Ensure the local image exists
if ! docker image inspect "$DOCKER_REPO" &>/dev/null; then
    echo "Error: Local image '$DOCKER_REPO' not found"
    exit 1
fi

# Tag and push with 'latest' tag
echo "Tagging and pushing with 'latest' tag..."
if ! docker tag "$DOCKER_REPO" "$REPO_NAME:latest"; then
    echo "Error: Failed to tag image with 'latest'"
    exit 1
fi

if ! docker push "$REPO_NAME:latest"; then
    echo "Error: Failed to push 'latest' tagged image"
    exit 1
fi

# Tag and push with specific tag
echo "Tagging and pushing with specific tag: $DOCKER_REPO_TAG..."
if ! docker tag "$DOCKER_REPO" "$REPO_NAME:$DOCKER_REPO_TAG"; then
    echo "Error: Failed to tag image with '$DOCKER_REPO_TAG'"
    exit 1
fi

if ! docker push "$DOCKER_IMAGE"; then
    echo "Error: Failed to push specifically tagged image"
    exit 1
fi

echo ""
echo "Push complete!"