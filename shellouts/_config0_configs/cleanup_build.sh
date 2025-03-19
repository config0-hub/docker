#!/usr/bin/env bash
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
#
# ------------------------------------------------------------------------------
# Docker Build Directory Initializer
# ------------------------------------------------------------------------------
# This script creates a clean working directory for Docker builds.
# It removes any existing directory and creates a fresh one, optionally
# within a subdirectory specified by MapDir.
#
# Environment variables:
#   - DOCKER_BUILD_DIR: Base directory for Docker builds (default: /var/tmp/docker/build)
#   - MapDir: Optional subdirectory name within DOCKER_BUILD_DIR
# ------------------------------------------------------------------------------

# Set default Docker build directory
export DOCKER_BUILD_DIR="${DOCKER_BUILD_DIR:-/var/tmp/docker/build}"
export WORKING_DIR="${DOCKER_BUILD_DIR}"

# If MapDir is provided, set working directory to a subdirectory
if [ -n "${MapDir}" ]; then
   export WORKING_DIR="${DOCKER_BUILD_DIR}/${MapDir}"
fi

# Navigate to root directory to ensure relative paths don't affect removal
cd /

# Remove existing directory (if any) and create fresh directory
echo "Creating clean working directory at: ${WORKING_DIR}"
rm -rf "${WORKING_DIR}"
mkdir -p "${WORKING_DIR}"

echo "Working directory initialized successfully."