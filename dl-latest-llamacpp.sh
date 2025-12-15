#!/bin/bash

# this is a bit hacky since it relies
# on pattern matching instead of a
# standardized way, but for me it
# works fine.
# change the pattern according to your
# os and architecture if necessary

REPO="ggml-org/llama.cpp"
FILE_PATTERN="macos-arm64.tar.gz" # specify your platform and architecture

API_URL="https://api.github.com/repos/$REPO/releases/latest"

# extract download url
# with jq search for 'assets'-Array and the specific
# name, so we get the correct download url
DOWNLOAD_URL=$(curl -s "$API_URL" | jq -r ".assets[] | select(.name | contains(\"$FILE_PATTERN\")) | .browser_download_url")

# check for url
if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find file with '$FILE_PATTERN' pattern."
    exit 1
fi

# else download the file
echo "downloading latest llama.cpp binaries..."
echo "URL: $DOWNLOAD_URL"
wget -O "$(basename "$DOWNLOAD_URL")" "$DOWNLOAD_URL"

echo "Download successful!"
