#!/bin/bash
# build_macos.sh
# Run this on macOS to build for Intel and Apple Silicon

set -e

echo "=== Building DeTree for macOS ==="
echo ""

# Check if on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script must run on macOS."
    exit 1
fi

# Install PyInstaller if needed
if ! command -v pyinstaller &> /dev/null; then
    echo "Installing PyInstaller..."
    pip install pyinstaller
fi

# Detect architecture
ARCH=$(uname -m)
echo "Building on: $ARCH"

if [[ "$ARCH" == "x86_64" ]] || [[ "$ARCH" == "amd64" ]]; then
    echo "Building for Intel macOS..."
    pyinstaller --onefile --name "detree-macos-intel" d2c2_cli.py
    echo "✓ Built: dist/detree-macos-intel"
fi

if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    echo "Building for Apple Silicon (ARM)..."
    pyinstaller --onefile --name "detree-macos-arm64" d2c2_cli.py
    echo "✓ Built: dist/detree-macos-arm64"
fi

# If on Intel, try to build universal binary
if [[ "$ARCH" == "x86_64" ]] || [[ "$ARCH" == "amd64" ]]; then
    echo ""
    echo "Note: For Apple Silicon build, run this script on an M1/M2/M3 Mac"
    echo "Or use: arch -arm64 bash build_macos.sh"
fi

echo ""
echo "=== Build Complete ==="
echo "Binaries in dist/:"
ls -lh dist/detree-macos-* 2>/dev/null || ls -lh dist/

echo ""
echo "Next steps:"
echo "1. Test binaries:"
echo "   ./dist/detree-macos-intel --help"
echo "   ./dist/detree-macos-arm64 --help"
echo ""
echo "2. Upload to GitHub Releases:"
echo "   gh release upload v1.0.0 dist/detree-macos-*"
