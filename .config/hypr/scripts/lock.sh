#!/usr/bin/env bash

pgrep -x hyprlock && exit 0

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
if [ -f /etc/NIXOS ]; then
  # NixOS: hyprlock installed via nix with proper dependencies
  # LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
  hyprlock -c "$TEMP_CONFIG"
else
  # Non-NixOS with Nix installed: force system EGL/Mesa to avoid conflicts
  __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json \
    LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:/usr/local/lib" \
    hyprlock -c "$TEMP_CONFIG"
fi

# Cleanup
rm -f "$TEMP_CONFIG"
