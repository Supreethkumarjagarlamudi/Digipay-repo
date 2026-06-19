#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Error: Please provide the GitHub Runner token as the first argument."
    echo "Usage: ./setup_runner.sh <YOUR_RUNNER_TOKEN>"
    exit 1
fi

TOKEN=$1
RUNNER_DIR="/Users/supreethkumarjagarlamudi/Documents/iosDevelopment/actions-runner"
VERSION="2.317.0"
TAR_FILE="actions-runner-osx-arm64-${VERSION}.tar.gz"
DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v2.317.0/${TAR_FILE}"

echo "=== GitHub Actions Self-Hosted Runner Setup ==="
echo "Target directory: $RUNNER_DIR"
echo "Architecture: macOS ARM64 (Apple Silicon)"

# Create folder outside git repo
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

# Download the runner tarball if not already present
if [ ! -f "$TAR_FILE" ]; then
    echo "Downloading Actions Runner v${VERSION}..."
    curl -o "$TAR_FILE" -L "$DOWNLOAD_URL"
else
    echo "Runner package already downloaded."
fi

# Extract the runner files
echo "Extracting installer..."
tar xzf "./$TAR_FILE"

# Configure the runner
echo "Configuring runner against your repository..."
./config.sh --url https://github.com/Supreethkumarjagarlamudi/Digipay-repo --token "$TOKEN" --unattended --replace

echo "==============================================="
echo "SUCCESS: Self-hosted runner setup completed!"
echo "To launch the runner, execute the following commands:"
echo "  cd $RUNNER_DIR"
echo "  ./run.sh"
echo "==============================================="
