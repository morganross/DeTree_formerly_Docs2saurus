#!/bin/bash
# build_all_architectures.sh
# Builds DeTree binaries for multiple architectures
# Requires: PyInstaller, Docker (for cross-compilation)

set -e

echo "=== Building DeTree for Multiple Architectures ==="
echo ""

# Detect if running on ARM or x86
ARCH=$(uname -m)
echo "Building on: $ARCH"

# Function to build for current architecture
build_native() {
    echo "Building native binary for $ARCH..."
    pyinstaller --onefile --name "detree-linux-$(uname -m)" d2c2_cli.py
    echo "✓ Native build complete: dist/detree-linux-$(uname -m)"
}

# Function to build using Docker (for cross-compilation)
build_with_docker() {
    local TARGET_ARCH=$1
    local DOCKER_IMAGE=$2
    
    echo "Building for $TARGET_ARCH using Docker ($DOCKER_IMAGE)..."
    
    docker run --rm -v "$(pwd):/src" -w /src "$DOCKER_IMAGE" \
        bash -c "
            pip install pyinstaller &&
            pyinstaller --onefile --name 'detree-linux-$TARGET_ARCH' d2c2_cli.py &&
            chown -R $(id -u):$(id -g) dist/
        "
    
    echo "✓ Docker build complete: dist/detree-linux-$TARGET_ARCH"
}

# Build native first
build_native

# Cross-compile for other architectures using Docker
if command -v docker &> /dev/null; then
    echo ""
    echo "Docker detected, building for other architectures..."
    
    # ARM64 build
    if [[ "$ARCH" != "aarch64" ]] && [[ "$ARCH" != "arm64" ]]; then
        echo ""
        build_with_docker "arm64" "arm64/python:3.11-slim"
    fi
    
    # x86_64 build (if on ARM)
    if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
        echo ""
        build_with_docker "x86_64" "python:3.11-slim"
    fi
else
    echo ""
    echo "Docker not found. Skipping cross-compilation."
    echo "To build for ARM64 on x86, install Docker and run:"
    echo "  docker run --rm -v \"\$(pwd):/src\" -w /src arm64/python:3.11-slim bash -c \"pip install pyinstaller && pyinstaller --onefile --name 'detree-linux-arm64' d2c2_cli.py\""
fi

echo ""
echo "=== Build Complete ==="
echo "Binaries in dist/:"
ls -lh dist/detree-linux-* 2>/dev/null || ls -lh dist/

echo ""
echo "Next steps:"
echo "1. Test binaries:"
echo "   ./dist/detree-linux-x86_64 --help"
echo "   ./dist/detree-linux-arm64 --help  # (on ARM device)"
echo ""
echo "2. Upload to GitHub Releases:"
echo "   gh release upload v1.0.0 dist/detree-linux-*"
