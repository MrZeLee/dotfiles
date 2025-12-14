#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/hyprpaper"

# Wait for hyprpaper to be ready
sleep 1

# Get all connected monitors
monitors=$(hyprctl monitors -j | jq -r '.[].name')

for monitor in $monitors; do
  cache_file="$CACHE_DIR/$monitor"
  if [ -L "$cache_file" ] && [ -e "$cache_file" ]; then
    wallpaper=$(readlink -f "$cache_file")
    hyprctl hyprpaper preload "$wallpaper"
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
  fi
done