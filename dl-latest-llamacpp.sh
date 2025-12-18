#!/bin/bash

# Llama.cpp Binary Downloader & Installer
# Downloads the latest release and optionally installs to ~/.local/bin
# Repository: ggml-org/llama.cpp

set -e  # Exit on errors

REPO="ggml-org/llama.cpp"
INSTALL_DIR="$HOME/.local/bin"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function for errors
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Detect platform and architecture automatically
detect_platform() {
    local os arch pattern
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    
    # Normalize OS name
    case "$os" in
        darwin) os="macos" ;;
        linux)  os="linux" ;;
        mingw*|msys*|cygwin*) os="windows" ;;
        *)      error_exit "Unsupported operating system: $os" ;;
    esac
    
    # Normalize architecture name
    case "$arch" in
        x86_64|amd64)   arch="x64" ;;
        aarch64|arm64)  arch="arm64" ;;
        *)              error_exit "Unsupported architecture: $arch" ;;
    esac
    
    # Build pattern based on OS
    if [ "$os" = "windows" ]; then
        pattern="${os}-${arch}.zip"
    else
        pattern="${os}-${arch}.tar.gz"
    fi
    
    echo "$pattern"
}

# Check if required tools are installed
check_dependencies() {
    local deps=("curl" "jq")
    
    # Add platform-specific dependencies
    if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]]; then
        deps+=("unzip")
    else
        deps+=("wget" "tar")
    fi
    
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error_exit "'$cmd' is not installed. Please install it first."
        fi
    done
}

# Extract archive based on file type
extract_archive() {
    local archive="$1"
    local dest="$2"
    
    if [[ "$archive" == *.zip ]]; then
        unzip -o "$archive" -d "$dest"
    else
        # Try with --strip-components first (removes wrapper folder if present)
        tar -xzf "$archive" -C "$dest" --strip-components=1 2>/dev/null \
            || tar -xzf "$archive" -C "$dest"
    fi
}

# Main script starts here
echo -e "${BLUE}=== Llama.cpp Binary Downloader ===${NC}"
echo ""

# Run dependency check
check_dependencies

# Detect platform automatically
FILE_PATTERN=$(detect_platform)
echo -e "Detected platform: ${GREEN}${FILE_PATTERN%.tar.gz}${NC}"
echo ""

# Fetch download URL from GitHub API
echo "Fetching latest release information..."
API_RESPONSE=$(curl -s "$API_URL")

DOWNLOAD_URL=$(echo "$API_RESPONSE" | jq -r ".assets[] | select(.name | contains(\"$FILE_PATTERN\")) | .browser_download_url")

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo -e "${YELLOW}Available assets:${NC}"
    echo "$API_RESPONSE" | jq -r '.assets[].name' | head -20
    echo ""
    error_exit "Could not find file matching pattern '$FILE_PATTERN'."
fi

FILENAME=$(basename "$DOWNLOAD_URL")

# Display version info
VERSION=$(echo "$API_RESPONSE" | jq -r ".tag_name")
echo -e "Found: ${GREEN}llama.cpp $VERSION${NC}"
echo ""

# Download the release
echo "Downloading: $FILENAME"
echo "URL: $DOWNLOAD_URL"
echo ""
wget --progress=bar:force -O "$FILENAME" "$DOWNLOAD_URL" || error_exit "Download failed"

echo ""
echo -e "${GREEN}Download successful!${NC}"
echo ""

# Offer installation
read -p "Do you want to install the binaries to $INSTALL_DIR? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Create installation directory if needed
    if [ ! -d "$INSTALL_DIR" ]; then
        echo "Creating $INSTALL_DIR..."
        mkdir -p "$INSTALL_DIR"
    fi
    
    echo "Extracting to $INSTALL_DIR..."
    extract_archive "$FILENAME" "$INSTALL_DIR"
    
    echo -e "${GREEN}Installation successful!${NC}"
    echo ""
    
    # Check if INSTALL_DIR is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo -e "${YELLOW}Note: $INSTALL_DIR is not in your PATH.${NC}"
        echo "Add the following line to your ~/.bashrc or ~/.zshrc:"
        echo -e "  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        echo ""
    fi
    
    # Offer cleanup
    read -p "Delete downloaded archive '$FILENAME'? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        rm "$FILENAME"
        echo "Archive deleted."
    fi
else
    echo ""
    echo "Archive downloaded: $FILENAME"
    echo "You can extract it manually with:"
    echo -e "  ${GREEN}tar -xzf $FILENAME${NC}"
fi

echo ""
echo -e "${BLUE}Done!${NC}"

