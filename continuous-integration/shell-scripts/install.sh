#!/bin/bash

### ENVIRONMENT VARIABLES ###
# See: https://broth.itch.zone/butler
BUTLER_CHANNEL="linux-amd64"
BUTLER_VERSION="15.24.0"

GODOT_VERSION="4.4-stable"
GODOT_PLATFORM="linux"
GODOT_EXT="x86_64"

GODOT_EDITOR="Godot_v${GODOT_VERSION}_${GODOT_PLATFORM}.${GODOT_EXT}"

# stops execution at first failed command
set -e

install_dependency () {
  local install_dir="$1"
  local absolute_path_to_zip="$2"
  local program_name="$3"
  local symlink_name="$4"

  mkdir -p "/usr/bin/${install_dir}"
  unzip "${absolute_path_to_zip}" -d "/usr/bin/${install_dir}"
  chmod +x "/usr/bin/${install_dir}/${program_name}"
  cd /usr/bin
  # create symbolic link for easy access
  ln -s "${install_dir}/${program_name}" "${symlink_name}"
}

echo "🗃️ ===> Downloading Butler, Godot, and Game Project...."
mkdir /downloads && cd /downloads

# parallelize the downloads
echo "https://broth.itch.zone/butler/${BUTLER_CHANNEL}/${BUTLER_VERSION}/archive/default butler.zip" >> url-list
echo "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/${GODOT_EDITOR}.zip godot-editor.zip" >> url-list
echo "https://github.com/hlimbo/GodotGithubActionsExample/archive/refs/heads/main.zip game-project.zip" >> url-list
echo "https://github.com/upx/upx/releases/download/v5.0.1/upx-5.0.1-amd64_linux.tar.xz upx-5.0.1-amd64_linux.tar.xz" >> url-list
# pipe in download url and filename for wget to download in parallel
# use 8 jobs max to run concurrently
# 1 = download url
# 2 = filename
cat url-list | parallel -j8 --col-sep ' ' wget --no-verbose {1} -O {2}
rm url-list

# wget --no-verbose "https://broth.itch.zone/butler/${BUTLER_CHANNEL}/${BUTLER_VERSION}/archive/default" -O "butler.zip"
# wget --no-verbose "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/${GODOT_EDITOR}.zip" -O "godot-editor.zip"
# wget --no-verbose "https://github.com/hlimbo/GodotGithubActionsExample/archive/refs/heads/main.zip" -O "game-project.zip"


echo "🔧 ===> Installing Butler and Godot Editor..."
install_dependency "butler-linux" "/downloads/butler.zip" "butler" "butler"
install_dependency "godot-editor" "/downloads/godot-editor.zip" "${GODOT_EDITOR}" "godot"
unzip /downloads/game-project.zip -d /downloads

# decompress, unzip, and install upx
cd /downloads
xz -d upx-5.0.1-amd64_linux.tar.xz
tar xvf upx-5.0.1-amd64_linux.tar
mv upx-5.0.1-amd64_linux /usr/bin
cd /usr/bin
ln -s upx-5.0.1-amd64_linux/upx upx