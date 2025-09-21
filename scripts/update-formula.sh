#!/usr/bin/env bash

set -euo pipefail

# Script to update chef-de-vibe formula with the latest release

VERSION=${1:-}

if [ -z "$VERSION" ]; then
    echo "Fetching latest release version..."
    VERSION=$(curl -s https://api.github.com/repos/fspv/chef-de-vibe/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)
    if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
        echo "No releases found, fetching latest tag..."
        VERSION=$(curl -s https://api.github.com/repos/fspv/chef-de-vibe/tags | grep '"name"' | head -1 | cut -d '"' -f 4)
    fi
fi

if [ -z "$VERSION" ]; then
    echo "Error: Could not determine version"
    exit 1
fi

echo "Updating formula to version: $VERSION"

BASE_URL="https://github.com/fspv/chef-de-vibe/releases/download/${VERSION}"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Download binaries and calculate checksums
echo "Downloading and calculating checksums..."

curl -sL "${BASE_URL}/chef-de-vibe-x86_64-apple-darwin" -o "$TEMP_DIR/chef-de-vibe-x86_64-apple-darwin"
SHA_MACOS_INTEL=$(sha256sum "$TEMP_DIR/chef-de-vibe-x86_64-apple-darwin" | awk '{print $1}')
echo "  macOS Intel: $SHA_MACOS_INTEL"

curl -sL "${BASE_URL}/chef-de-vibe-aarch64-apple-darwin" -o "$TEMP_DIR/chef-de-vibe-aarch64-apple-darwin"
SHA_MACOS_ARM=$(sha256sum "$TEMP_DIR/chef-de-vibe-aarch64-apple-darwin" | awk '{print $1}')
echo "  macOS ARM: $SHA_MACOS_ARM"

curl -sL "${BASE_URL}/chef-de-vibe-x86_64-unknown-linux-gnu" -o "$TEMP_DIR/chef-de-vibe-x86_64-unknown-linux-gnu"
SHA_LINUX=$(sha256sum "$TEMP_DIR/chef-de-vibe-x86_64-unknown-linux-gnu" | awk '{print $1}')
echo "  Linux: $SHA_LINUX"

# Remove 'v' prefix if present for version string
VERSION_NUMBER="${VERSION#v}"

# Update the formula file
FORMULA_FILE="Formula/chef-de-vibe.rb"

echo "Updating $FORMULA_FILE..."

# Create a backup
cp "$FORMULA_FILE" "$FORMULA_FILE.bak"

# Update version
sed -i.tmp "s/version \".*\"/version \"$VERSION_NUMBER\"/" "$FORMULA_FILE"

# Update URLs
sed -i.tmp "s|download/v[^/]*/chef-de-vibe|download/$VERSION/chef-de-vibe|g" "$FORMULA_FILE"

# Update SHA256 checksums
if grep -q "PLACEHOLDER_SHA256" "$FORMULA_FILE"; then
    # First time setup with placeholders
    sed -i.tmp "s/PLACEHOLDER_SHA256_MACOS_INTEL/$SHA_MACOS_INTEL/" "$FORMULA_FILE"
    sed -i.tmp "s/PLACEHOLDER_SHA256_MACOS_ARM/$SHA_MACOS_ARM/" "$FORMULA_FILE"
    sed -i.tmp "s/PLACEHOLDER_SHA256_LINUX/$SHA_LINUX/" "$FORMULA_FILE"
else
    # Update existing checksums
    # Find and replace SHA256 for Intel macOS
    sed -i.tmp "/x86_64-apple-darwin/,/sha256/ s/sha256 \"[^\"]*\"/sha256 \"$SHA_MACOS_INTEL\"/" "$FORMULA_FILE"
    
    # Find and replace SHA256 for ARM macOS
    sed -i.tmp "/aarch64-apple-darwin/,/sha256/ s/sha256 \"[^\"]*\"/sha256 \"$SHA_MACOS_ARM\"/" "$FORMULA_FILE"
    
    # Find and replace SHA256 for Linux
    sed -i.tmp "/x86_64-unknown-linux-gnu/,/sha256/ s/sha256 \"[^\"]*\"/sha256 \"$SHA_LINUX\"/" "$FORMULA_FILE"
fi

# Clean up temp files
rm -f "$FORMULA_FILE.tmp"
rm -f "$FORMULA_FILE.bak"

echo "Formula updated successfully!"
echo ""
echo "To test the formula locally:"
echo "  brew install --build-from-source ./Formula/chef-de-vibe.rb"
echo ""
echo "To commit and push:"
echo "  git add Formula/chef-de-vibe.rb"
echo "  git commit -m \"Update chef-de-vibe to $VERSION\""
echo "  git push"