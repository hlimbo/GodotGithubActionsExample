#!/bin/bash
ZIP_FILENAME="game-windows.zip"
ZIP_FILENAME_WEB="game-web.zip"
ITCH_IO_USERNAME="hlimbo"
ITCH_IO_PROJECT_NAME="github-actions-godot-game-example"
ITCH_IO_PLATFORM="windows-beta"
ITCH_IO_PLATFORM_WEB="web"

EXPORT_PATHS=("windows/release" "web/release")
PLATFORMS=("Windows Desktop" "Web")
ZIP_FILENAMES=("game-windows.zip" "game-web.zip")
ITCH_IO_PLATFORMS=("windows-beta" "web")

PROJECT_NAME="GodotGithubActionsExample-main"

# stops execution at first failed command
set -e

# export_presets.cfg contains info about how to build a godot game
mv /export_presets.cfg "/downloads/${PROJECT_NAME}"
for export_path in ${EXPORT_PATHS[@]}; do
	mkdir -p "/downloads/${PROJECT_NAME}/exports/${export_path}"
done
# mkdir -p "/downloads/${PROJECT_NAME}/exports/mac/release"
cd "/downloads/${PROJECT_NAME}"

# build the project
for i in ${!PLATFORMS[@]}; do
	platform="${PLATFORMS[$i]}"
	echo "🛠️ ===> Building godot project for ${platform}..."
	godot --headless --export-release "${platform}"
done

echo "💾  ===>  Compressing the Executable for MAXIMUM EFFICIENCY!  ===> 💾"
upx /downloads/$PROJECT_NAME/exports/windows/release/*.exe

for i in ${!ZIP_FILENAMES[@]}; do
	zip_filename="${ZIP_FILENAMES[$i]}"
    export_path="${EXPORT_PATHS[$i]}"
	echo "🤐 ===> zipping $PROJECT_NAME to $zip_filename"
	# -j option discards intermediate folders and only zips file contained in the leaf nodes
	zip -j "/$zip_filename" /downloads/$PROJECT_NAME/exports/$export_path/*
done


for i in ${ITCH_IO_PLATFORMS[@]}; do
	itch_io_platform="${ITCH_IO_PLATFORMS[$i]}"
	zip_filename="${ZIP_FILENAMES[$i]}"
	ITCH_IO_PATH="${ITCH_IO_USERNAME}/${ITCH_IO_PROJECT_NAME}:${itch_io_platform}"  
	echo "🤖 ===> uploading $zip_filename to itch.io..."
	butler push "/${zip_filename}" $ITCH_IO_PATH
	butler status $ITCH_IO_PATH
done
