#!/bin/bash

# ========= CONFIG =========
REPO="hordenode/powered-repo"
APP_NAME="Powered.app"
DEST_DIR="/Applications"
TMP_DIR="/tmp/powered.dmg"
DMG_NAME="powered-latest.dmg"
# ===========================

PURPLE="\033[1;35m"
WHITE="\033[0;37m"
RESET="\033[0m"

mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

echo -e "${PURPLE}[Powered]${WHITE} Checking latest release...${RESET}"
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/tags" | grep 'name' | head -n 1 | cut -d '"' -f 4)

if [ -z "$LATEST_TAG" ]; then
    echo -e "${PURPLE}[Powered]${WHITE} Failed to fetch latest release tag.${RESET}"
    exit 1
fi

VERSION="${LATEST_TAG#v}"
DMG_FILE_NAME="moon-${VERSION}.dmg"
DMG_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$DMG_FILE_NAME"

echo -e "${PURPLE}[Powered]${WHITE} Downloading $DMG_FILE_NAME...${RESET}"
curl -L -o "$DMG_NAME" "$DMG_URL"

echo -e "${PURPLE}[Powered]${WHITE} Mounting DMG...${RESET}"
MOUNT_POINT=$(hdiutil attach "$DMG_NAME" | grep Volumes | awk '{print $3}')

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
