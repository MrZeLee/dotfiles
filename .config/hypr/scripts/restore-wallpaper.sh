#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/hyprpaper"

# Check if hyprpaper is running and wait for it to be ready
MAX_ATTEMPTS=10
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  if pgrep -x hyprpaper >/dev/null 2>&1; then
    # Process exists, check if socket is responsive
    if hyprctl hyprpaper listloaded >/dev/null 2>&1; then
      echo "hyprpaper is ready"
      break
    fi
  fi

  ATTEMPT=$((ATTEMPT + 1))
  if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "Error: hyprpaper is not running or not responding after $MAX_ATTEMPTS attempts"
    exit 1
  fi

  sleep 0.5
done

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
