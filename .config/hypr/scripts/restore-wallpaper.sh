#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/hyprpaper"

# Wait for hyprpaper to be ready
sleep 1

# Get all connected monitors and iterate properly using compact JSON
hyprctl monitors -j | jq -c '.[]' | while read -r monitor; do
  monitor_description=$(echo "$monitor" | jq -r '.description')
  monitor_name=$(echo "$monitor" | jq -r '.name')
  cache_file="$CACHE_DIR/${monitor_description}-monitor"
  if [ -L "$cache_file" ] && [ -e "$cache_file" ]; then
    wallpaper=$(readlink -f "$cache_file")
    hyprctl hyprpaper preload "$wallpaper"
    hyprctl hyprpaper wallpaper "$monitor_name,$wallpaper"
  fi
done
