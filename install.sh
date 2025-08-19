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

# Extract DMG URL from assets containing 'powered' (case-insensitive)
DMG_URL=$(echo "$API_JSON" \
  | grep -i 'browser_download_url' \
  | grep -i 'powered.*\.dmg' \
  | head -n 1 \
  | cut -d '"' -f 4)

if [ -z "$DMG_URL" ]; then
    echo -e "${PURPLE}[Powered]${WHITE} Failed to find a DMG in the latest release.${RESET}"
    exit 1
fi

DMG_FILE_NAME=$(basename "$DMG_URL")

echo -e "${PURPLE}[Powered]${WHITE} Downloading $DMG_FILE_NAME...${RESET}"
curl -L -o "$DMG_FILE_NAME" "$DMG_URL"

# Check if the DMG downloaded properly
if [ ! -s "$DMG_FILE_NAME" ]; then
    echo -e "${PURPLE}[Powered]${WHITE} Download failed or file is empty.${RESET}"
    exit 1
fi

echo -e "${PURPLE}[Powered]${WHITE} Mounting DMG...${RESET}"
MOUNT_POINT=$(hdiutil attach "$DMG_FILE_NAME" -nobrowse -quiet | grep Volumes | awk '{print $3}')

if [ -z "$MOUNT_POINT" ]; then
    echo -e "${PURPLE}[Powered]${WHITE} Failed to mount DMG.${RESET}"
    exit 1
fi

echo -e "${PURPLE}[Powered]${WHITE} Installing to $DEST_DIR...${RESET}"
cp -R "$MOUNT_POINT/$APP_NAME" "$DEST_DIR/"

echo -e "${PURPLE}[Powered]${WHITE} Unmounting...${RESET}"
hdiutil detach "$MOUNT_POINT" -quiet

echo -e "${PURPLE}[Powered]${WHITE} Cleaning up...${RESET}"
rm -rf "$TMP_DIR"

echo -e "${PURPLE}[Powered]${WHITE} Installed successfully on your system.${RESET}"
