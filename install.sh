#!/bin/bash

# ========= CONFIG =========
REPO="hordenode/powered-repo"
APP_NAME="Powered.app"
DEST_DIR="/Applications"
TMP_DIR="/tmp/powered_installer"
# ===========================

PURPLE="\033[1;35m"
WHITE="\033[0;37m"
RESET="\033[0m"

mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

echo -e "${PURPLE}[Powered]${WHITE} Checking latest release...${RESET}"

# Get the latest release info from GitHub API
API_JSON=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

# Extract DMG browser_download_url containing 'powered' (case-insensitive)
DMG_URL=$(echo "$API_JSON" | grep -i 'browser_download_url' | grep -i 'powered.*\.dmg' | cut -d '"' -f 4 | head -n 1)

if [ -z "$DMG_URL" ]; then
    echo -e "${PURPLE}[Powered]${WHITE} Failed to find a DMG with 'powered' in the release.${RESET}"
    exit 1
fi

DMG_FILE_NAME=$(basename "$DMG_URL")

echo -e "${PURPLE}[Powered]${WHITE} Downloading $DMG_FILE_NAME...${RESET}"
curl -L -o "$DMG_FILE_NAME" "$DMG_URL"

echo -e "${PURPLE}[Powered]${WHITE} Mounting DMG...${RESET}"
MOUNT_POINT=$(hdiutil attach "$DMG_FILE_NAME" | grep Volumes | awk '{print $3}')

if [ -z "$MOUNT_POINT" ]; then
    echo -e "${PURPLE}[Powered]${WHITE} Failed to mount DMG.${RESET}"
    exit 1
fi

echo -e "${PURPLE}[Powered]${WHITE} Installing to $DEST_DIR...${RESET}"
cp -R "$MOUNT_POINT/$APP_NAME" "$DEST_DIR/"

echo -e "${PURPLE}[Powered]${WHITE} Unmounting...${RESET}"
hdiutil detach "$MOUNT_POINT" > /dev/null

echo -e "${PURPLE}[Powered]${WHITE} Cleaning up...${RESET}"
rm -rf "$TMP_DIR"

echo -e "${PURPLE}[Powered]${WHITE} Installed successfully on your system.${RESET}"
