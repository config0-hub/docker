#!/bin/bash
#
# Docker Build and Push Script
#
# This script builds a Docker image from a specified Dockerfile and pushes it to a repository.
# It supports passing build arguments to the Docker build process through environment variables.
#
# Usage:
#   ./script.sh
#
# Environment Variables (all have defaults):
#   DOCKER_BUILD_DIR     - Directory containing the build files (default: /var/tmp/docker/build)
#   DOCKER_FILE          - Name of the Dockerfile (default: Dockerfile)
#   DOCKER_IMAGE_TAG     - Tag for the Docker image (default: test)
#   REPOSITORY_URI       - URI of the Docker repository (default: test)
#   DOCKER_ENV_FIELDS    - Comma-separated list of environment variables to pass as build args (default: None)
#   DOCKER_ENV_FIELDS_B64 - Base64 encoded fields (currently unused) (default: None)
#
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

# Set default values for environment variables
export DOCKER_BUILD_DIR=${DOCKER_BUILD_DIR:=/var/tmp/docker/build}
export DOCKER_FILE=${DOCKER_FILE:=Dockerfile}
export DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG:=test}
export REPOSITORY_URI=${REPOSITORY_URI:=test}
export DOCKER_ENV_FIELDS=${DOCKER_ENV_FIELDS:=None}
export DOCKER_ENV_FIELDS_B64=${DOCKER_ENV_FIELDS_B64:=None}

# Change to the build directory
cd "$DOCKER_BUILD_DIR" || {
    echo "Error: Failed to change to build directory $DOCKER_BUILD_DIR"
    exit 1
}

# Initialize build arguments
ARGS=""

# Prepare the Docker build command
if [ "$DOCKER_ENV_FIELDS" == "None" ]; then
    # Simple build without additional build arguments
    BUILD_CMD="docker build -t $REPOSITORY_URI:$DOCKER_IMAGE_TAG . -f $DOCKER_FILE"
else
    # Add build arguments from environment variables
    for env_var_name in ${DOCKER_ENV_FIELDS//,/ }; do
        env_var_value=$(eval echo $`eval 'echo "$env_var_name"'`)
        ARGS="--build-arg ${env_var_name}=${env_var_value} ${ARGS}"
    done

    BUILD_CMD="docker build $ARGS -t $REPOSITORY_URI:$DOCKER_IMAGE_TAG . -f $DOCKER_FILE"
fi

# Display and execute the build command
echo "###############################################################"
echo "BUILD_CMD: $BUILD_CMD"
echo "###############################################################"

$BUILD_CMD || {
    echo "Error: Docker build failed"
    exit 10
}

# Push the image to the repository
echo "###############################################################"
echo "# Pushing image: $REPOSITORY_URI:$DOCKER_IMAGE_TAG"
echo "###############################################################"

docker push "$REPOSITORY_URI:$DOCKER_IMAGE_TAG" || {
    echo "Error: Docker push failed"
    exit 8
}

echo "Image successfully built and pushed"