#!/bin/bash
ZIP_FILENAME="game-windows.zip"
ITCH_IO_USERNAME="hlimbo"
ITCH_IO_PROJECT_NAME="github-actions-godot-game-example"
ITCH_IO_PLATFORM="windows-beta"
TARGET_PLATFORM="Windows Desktop"
PROJECT_NAME="GodotGithubActionsExample-main"

# stops execution at first failed command
set -e

echo "🛠️ ===> Building godot project for $TARGET_PLATFORM..."

# export_presets.cfg contains info about how to build a godot game
mv /export_presets.cfg "/downloads/${PROJECT_NAME}"
mkdir -p "/downloads/${PROJECT_NAME}/exports/windows/release"
cd "/downloads/${PROJECT_NAME}"
# build the project
godot --headless --export-release "$TARGET_PLATFORM"

echo "🤐 ===> zipping $PROJECT_NAME to $ZIP_FILENAME"
# -j option discards intermediate folders and only zips file contained in the leaf nodes
zip -j "/${ZIP_FILENAME}" /downloads/$PROJECT_NAME/exports/windows/release/*

ITCH_IO_PATH="${ITCH_IO_USERNAME}/${ITCH_IO_PROJECT_NAME}:${ITCH_IO_PLATFORM}"  
echo "🤖 ===> uploading $ZIP_FILENAME to itch.io..."
butler push "/${ZIP_FILENAME}" $ITCH_IO_PATH
butler status $ITCH_IO_PATH