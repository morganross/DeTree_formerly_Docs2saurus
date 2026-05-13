#!/bin/bash
# build_linux_binaries.sh
# Run this on a Linux machine to build for x86_64 and ARM64

set -e

echo "=== Building DeTree Linux Binaries ==="
echo ""

# Check if on Linux
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "Error: This script must run on Linux."
    echo "For Windows: Use WSL"
    echo "For macOS: Use build_macos.sh"
    exit 1
fi

# Install PyInstaller if needed
if ! command -v pyinstaller &> /dev/null; then
    echo "Installing PyInstaller..."
    pip install pyinstaller
fi

# Build for native architecture
ARCH=$(uname -m)
echo "Building for native architecture: $ARCH"
pyinstaller --onefile --name "detree-linux-$ARCH" d2c2_cli.py
echo "✓ Built: dist/detree-linux-$ARCH"

# Cross-compile for ARM64 if on x86_64
if [[ "$ARCH" == "x86_64" ]] || [[ "$ARCH" == "amd64" ]]; then
    if command -v docker &> /dev/null; then
        echo ""
        echo "Cross-compiling for ARM64 using Docker..."
        docker run --rm -v "$(pwd):/src" -w /src arm64/python:3.11-slim bash -c "
            pip install pyinstaller &&
            pyinstaller --onefile --name 'detree-linux-arm64' d2c2_cli.py &&
            chown -R $(id -u):$(id -g) dist/
        "
        echo "✓ Built: dist/detree-linux-arm64"
    else
        echo ""
        echo "Docker not found. Skipping ARM64 build."
        echo "To build for ARM64, install Docker or run on an ARM device."
    fi
fi

# Cross-compile for x86_64 if on ARM
if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    if command -v docker &> /dev/null; then
        echo ""
        echo "Cross-compiling for x86_64 using Docker..."
        docker run --rm -v "$(pwd):/src" -w /src python:3.11-slim bash -c "
            pip install pyinstaller &&
            pyinstaller --onefile --name 'detree-linux-x86_64' d2c2_cli.py &&
            chown -R $(id -u):$(id -g) dist/
        "
        echo "✓ Built: dist/detree-linux-x86_64"
    else
        echo ""
        echo "Docker not found. Skipping x86_64 build."
    fi
fi

echo ""
echo "=== Build Complete ==="
echo "Binaries in dist/:"
ls -lh dist/detree-linux-* 2>/dev/null || ls -lh dist/

echo ""
echo "Next steps:"
echo "1. Test binaries:"
echo "   ./dist/detree-linux-$ARCH --help"
echo ""
echo "2. Upload to GitHub Releases:"
echo "   gh release upload v1.0.0 dist/detree-linux-*"
echo ""
echo "Or create a release manually on GitHub and upload the binaries."
