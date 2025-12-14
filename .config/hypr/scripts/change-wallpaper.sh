#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/waypaper/wallpapers"
CACHE_DIR="$HOME/.cache/hyprpaper"

mkdir -p "$CACHE_DIR"

activemonitor=$(hyprctl activeworkspace -j | jq --raw-output '.monitor')
if [ -z "$activemonitor" ]; then
  echo "No active Monitor found."
  exit 1
fi

# Get monitor resolution
monitor_info=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$activemonitor\")")
x=$(echo "$monitor_info" | jq -r '.width')
y=$(echo "$monitor_info" | jq -r '.height')

# Calculate the aspect ratio and format it to 2 decimal places
aspect_ratio=$(echo "scale=2; $x/$y" | bc | awk '{printf "%.2f", $0}')

# Treat 16:10 (1.60) as 16:9 (1.77) for wallpaper selection
if [ "$aspect_ratio" = "1.60" ]; then
  aspect_ratio="1.77"
fi

# Get a random wallpaper from the appropriate folder
folder="$WALLPAPER_DIR/$aspect_ratio"
if [ ! -d "$folder" ]; then
  echo "No wallpaper folder for aspect ratio $aspect_ratio"
  exit 1
fi

wallpaper=$(find "$folder" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)
if [ -z "$wallpaper" ]; then
  echo "No wallpapers found in $folder"
  exit 1
fi

# Save wallpaper as symlink in cache
ln -sf "$wallpaper" "$CACHE_DIR/$activemonitor"

# Preload and set wallpaper via hyprpaper IPC
hyprctl hyprpaper preload "$wallpaper"
hyprctl hyprpaper wallpaper "$activemonitor,$wallpaper"

# If there's only one monitor connected, also apply to all monitors
monitor_count=$(hyprctl monitors -j | jq 'length')
if [ "$monitor_count" -eq 1 ]; then
  hyprctl hyprpaper wallpaper ",$wallpaper"
fi