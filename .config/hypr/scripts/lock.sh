#!/usr/bin/env bash

pgrep -x hyprlock && exit 0

# Set library path for locally built hyprlock and dependencies
export LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Hyprlock configuration using cached wallpapers from hyprpaper
# Wallpapers are stored as symlinks in ~/.cache/hyprpaper/MONITOR_NAME

CACHE_DIR="$HOME/.cache/hyprpaper"
BASE_CONFIG="$HOME/.config/hypr/hyprlock.conf"
TEMP_CONFIG="/tmp/hyprlock-$$.conf"

# Get current active monitors
active_monitors=($(hyprctl monitors -j | jq -r '.[].name'))

# Start with the base config (contains general, input-field, labels)
cp "$BASE_CONFIG" "$TEMP_CONFIG"

# Generate background sections for each monitor
for mon in "${active_monitors[@]}"; do
  wallpaper_link="$CACHE_DIR/$mon"

  if [ -L "$wallpaper_link" ]; then
    # Resolve symlink to get actual wallpaper path
    wallpaper=$(readlink -f "$wallpaper_link")

    if [ -f "$wallpaper" ]; then
      cat >>"$TEMP_CONFIG" <<EOF

background {
  monitor = $mon
  path = $wallpaper
  blur_passes = 3
  blur_size = 8
  noise = 0.0117
  contrast = 0.8916
  brightness = 0.8172
  vibrancy = 0.1696
  vibrancy_darkness = 0.0
}
EOF
    fi
  fi
done

# Run hyprlock with the generated config
hyprlock -c "$TEMP_CONFIG"

# Cleanup
rm -f "$TEMP_CONFIG"
