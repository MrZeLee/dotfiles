#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/waypaper/wallpapers"
CACHE_DIR="$HOME/.cache/hyprpaper"

mkdir -p "$CACHE_DIR"

set_wallpaper_for_monitor() {
  local monitor_name="$1"
  local monitor_desc="$2"

  # Wait a bit for the monitor to be fully initialized
  sleep 1

  # Check if there's a cached wallpaper for this monitor (using description as cache key)
  cache_file="$CACHE_DIR/${monitor_desc}-monitor"
  if [ -L "$cache_file" ] && [ -e "$cache_file" ]; then
    wallpaper=$(readlink -f "$cache_file")
    hyprctl hyprpaper preload "$wallpaper"
    hyprctl hyprpaper wallpaper "$monitor_name,$wallpaper"
    return
  fi

  # No cache - select wallpaper based on aspect ratio
  monitor_info=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor_name\")")
  if [ -z "$monitor_info" ]; then
    echo "Monitor $monitor_name not found"
    return
  fi

  x=$(echo "$monitor_info" | jq -r '.width')
  y=$(echo "$monitor_info" | jq -r '.height')

  aspect_ratio=$(echo "scale=2; $x/$y" | bc | awk '{printf "%.2f", $0}')

  # Treat 16:10 (1.60) as 16:9 (1.77) for wallpaper selection
  if [ "$aspect_ratio" = "1.60" ]; then
    aspect_ratio="1.77"
  fi

  folder="$WALLPAPER_DIR/$aspect_ratio"
  if [ ! -d "$folder" ]; then
    echo "No wallpaper folder for aspect ratio $aspect_ratio"
    return
  fi

  wallpaper=$(find "$folder" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)
  if [ -z "$wallpaper" ]; then
    echo "No wallpapers found in $folder"
    return
  fi

  # Cache the wallpaper selection (using description as cache key)
  ln -sf "$wallpaper" "$CACHE_DIR/${monitor_desc}-monitor"

  # Set the wallpaper
  hyprctl hyprpaper preload "$wallpaper"
  hyprctl hyprpaper wallpaper "$monitor_name,$wallpaper"

  echo "Set wallpaper for $monitor_name: $wallpaper"
}

handle_event() {
  while read -r line; do
    case "$line" in
    monitoraddedv2*)
      echo "$line" >>/tmp/monitor_event.log
      data="${line#monitoraddedv2>>}"
      IFS=',' read -r monitor_id monitor_name monitor_desc <<<"$data"
      echo "Monitor added: $monitor_name ($monitor_desc)"
      set_wallpaper_for_monitor "$monitor_name" "$monitor_desc"
      ;;
    esac
  done
}

# Listen to Hyprland socket for events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | handle_event
