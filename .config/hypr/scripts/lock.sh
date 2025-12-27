#!/usr/bin/env bash

pgrep -x hyprlock && exit 0

# Set library path for locally built hyprlock and dependencies
export LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Hyprlock configuration using cached wallpapers from hyprpaper
# Wallpapers are stored as symlinks in ~/.cache/hyprpaper/MONITOR_NAME

CACHE_DIR="$HOME/.cache/hyprpaper"
BASE_CONFIG="$HOME/.config/hypr/hyprlock.conf"
TEMP_CONFIG="/tmp/hyprlock-$$.conf"

# Start with the base config (contains general, input-field, labels)
cp "$BASE_CONFIG" "$TEMP_CONFIG"

# Generate background sections for each monitor
hyprctl monitors -j | jq -c '.[]' | while read -r monitor; do
  monitor_description=$(echo "$monitor" | jq -r '.description')
  monitor_name=$(echo "$monitor" | jq -r '.name')
  wallpaper_link="$CACHE_DIR/${monitor_description}-monitor"

  if [ -L "$wallpaper_link" ] && [ -e "$wallpaper_link" ]; then
    wallpaper=$(readlink -f "$wallpaper_link")

    cat >>"$TEMP_CONFIG" <<EOF

background {
  monitor = $monitor_name
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
done

# Run hyprlock with the generated config
hyprlock -c "$TEMP_CONFIG"

# Cleanup
rm -f "$TEMP_CONFIG"
