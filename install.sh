#!/bin/bash
# install.sh - One-click installer for DeTree
# Supports: Linux (x86_64, ARM64), macOS, Windows (with WSL)
# Usage: curl -sSL https://raw.githubusercontent.com/yourusername/DeTree/main/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== DeTree Installer ===${NC}"
echo "Installing DeTree - Convert nested text lists into directory structures"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

echo -e "${YELLOW}Detected: $OS ($ARCH)${NC}"

# Function to install via pip (works everywhere with Python)
install_via_pip() {
    echo -e "${GREEN}Installing via pip...${NC}"
    
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        echo -e "${RED}Error: Python 3 is not installed${NC}"
        echo "Please install Python 3.6+ and try again"
        exit 1
    fi
    
    PYTHON_CMD="python3"
    if ! command -v python3 &> /dev/null; then
        PYTHON_CMD="python"
    fi
    
    echo "Using Python: $($PYTHON_CMD --version)"
    
    # Install detree
    $PYTHON_CMD -m pip install detree --user
    
    # Verify installation
    if command -v detree &> /dev/null; then
        echo -e "${GREEN}✓ DeTree installed successfully!${NC}"
        detree --help
    else
        echo -e "${YELLOW}detree installed. You may need to add ~/.local/bin to your PATH${NC}"
        echo "Run: export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "Then: detree --help"
    fi
}

# Function to download and install binary
install_via_binary() {
    local BINARY_URL=""
    local BINARY_NAME="detree"
    
    # Determine correct binary for architecture
    if [[ "$OS" == "Linux" ]]; then
        if [[ "$ARCH" == "x86_64" ]] || [[ "$ARCH" == "amd64" ]]; then
            BINARY_URL="https://github.com/yourusername/DeTree/releases/latest/download/detree-linux-x86_64"
            echo -e "${GREEN}Detected: Linux x86_64${NC}"
        elif [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
            BINARY_URL="https://github.com/yourusername/DeTree/releases/latest/download/detree-linux-arm64"
            echo -e "${GREEN}Detected: Linux ARM64 (aarch64)${NC}"
        else
            echo -e "${YELLOW}Unsupported architecture: $ARCH${NC}"
            echo "Falling back to pip installation..."
            install_via_pip
            return
        fi
    elif [[ "$OS" == "Darwin" ]]; then
        BINARY_URL="https://github.com/yourusername/DeTree/releases/latest/download/detree-macos"
        echo -e "${GREEN}Detected: macOS${NC}"
    else
        echo -e "${YELLOW}Unsupported OS: $OS${NC}"
        echo "Falling back to pip installation..."
        install_via_pip
        return
    fi
    
    echo -e "${GREEN}Downloading binary...${NC}"
    
    # Download binary
    if command -v curl &> /dev/null; then
        curl -sSL -o /tmp/detree "$BINARY_URL"
    elif command -v wget &> /dev/null; then
        wget -q -O /tmp/detree "$BINARY_URL"
    else
        echo -e "${RED}Error: Neither curl nor wget found${NC}"
        exit 1
    fi
    
    # Make executable
    chmod +x /tmp/detree
    
    # Install to /usr/local/bin (requires sudo) or ~/.local/bin
    if [[ -w /usr/local/bin ]]; then
        mv /tmp/detree /usr/local/bin/detree
        echo -e "${GREEN}✓ DeTree installed to /usr/local/bin/detree${NC}"
    else
        mkdir -p ~/.local/bin
        mv /tmp/detree ~/.local/bin/detree
        echo -e "${GREEN}✓ DeTree installed to ~/.local/bin/detree${NC}"
        echo -e "${YELLOW}Make sure ~/.local/bin is in your PATH${NC}"
        echo "Run: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    
    # Verify
    detree --help
}

# Main installation logic
echo ""
echo "Choose installation method:"
echo "1) Binary (fastest, no Python required) - Recommended for Linux/macOS"
echo "2) pip (works everywhere with Python)"
echo ""
read -p "Enter choice [1-2] (default: 1): " choice

if [[ "$choice" == "2" ]]; then
    install_via_pip
else
    install_via_binary
fi

echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo "Quick test:"
echo "  echo 'Test Item' | detree /dev/stdin test_output"
echo ""
echo "Full documentation: https://github.com/yourusername/DeTree"
