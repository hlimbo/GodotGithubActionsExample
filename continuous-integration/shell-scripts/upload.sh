#!/bin/bash
ITCH_IO_USERNAME="hlimbo"
ITCH_IO_PROJECT_NAME="github-actions-godot-game-example"

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

retry_push() {
  local zip_filename="$1"
  local itch_io_path="$2"
  # convert string to int
  local max_retries=$(($3))
  
  # exponential backoff -- kind of costly as there is only 2000 free minutes per month on Github Actions
  local delay_secs=1
  local echo_output=$(butler push "${zip_filename}" "${itch_io_path}")
  local has_error=$(echo "$echo_output" | tail -n 1)
  local i=0
  # enable case insensitive option for string substring comparison
  shopt -s nocasematch
  while (( $i < $max_retries )) && [[ $has_error =~ "error" ]]; do
    # debug log msg output to stderr so it doesn't get captured as a return value
    echo "⚠️  ===>  Failed to push ${zip_filename} to ${itch_io_path} Retrying in $delay_secs second(s)..." >&2
    echo "⚠️  ===>  ${has_error}" >&2

    sleep $delay_secs
    
    delay_secs=$(($delay_secs*2))
    i=$(($i+1))

    # rerun butler until successful or reach max retry count
    echo_output=$(butler push "${zip_filename}" "${itch_io_path}")
    has_error=$(echo "$echo_output" | tail -n 1)
  done

  # return value
  if [[ $has_error =~ "error" ]]; then
    echo 1
  else
    echo 0
  fi
}


for i in ${!ITCH_IO_PLATFORMS[@]}; do
	itch_io_platform="${ITCH_IO_PLATFORMS[$i]}"
	zip_filename="/${ZIP_FILENAMES[$i]}"
	ITCH_IO_PATH="${ITCH_IO_USERNAME}/${ITCH_IO_PROJECT_NAME}:${itch_io_platform}"  
	echo "🤖 ===> uploading $zip_filename to itch.io..."
	# get status code from last echo statement
	retry_count=3
	push_status=$(retry_push "$zip_filename" "$ITCH_IO_PATH" "$retry_count" | tail -n 1)

	if (( $push_status != 0 )); then
	  echo "❌  ===>  error uploading $zip_filename to $ITCH_IO_PATH"
	else
	  echo "✅  ===>  successfully uploaded $zip_filename to $ITCH_IO_PATH"
	fi
done

target="${ITCH_IO_USERNAME}/${ITCH_IO_PROJECT_NAME}"
butler status $target --show-all-files
