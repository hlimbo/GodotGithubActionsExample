#!/bin/bash

echo "🌐 ===> Updating Ubuntu Repos..."
# update ubuntu package repository locations
apt-get update --assume-yes --quiet
# install utilities and libfontconfig1 Godot dependency
apt-get install --assume-yes --quiet wget unzip zip parallel libfontconfig1