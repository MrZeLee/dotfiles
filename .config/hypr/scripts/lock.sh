#!/usr/bin/env bash

# Get waypaper list
waypaper_list=$(waypaper --list)
if [ -z "$waypaper_list" ]; then
  echo "No wallpaper list found."
  exit 1
fi

# Parse wallpaper assignments from waypaper
assigned_monitors=()
declare -A wallpapers
all_wallpaper=""

while read -r elem; do
  monitor=$(echo "$elem" | jq -r '.monitor')
  wallpaper=$(echo "$elem" | jq -r '.wallpaper')
  wallpapers["$monitor"]="$wallpaper"
  assigned_monitors+=("$monitor")

  # Save "All" wallpaper if exists
  if [[ "$monitor" == "All" ]]; then
    all_wallpaper="$wallpaper"
  fi
done < <(echo "$waypaper_list" | jq -c '.[]')

# Get current active monitors
active_monitors=($(hyprctl monitors -j | jq -r '.[].name'))

# Initialize the swaylock command
swaylock_cmd="swaylock -f -e -s stretch -c 000000"

# Loop over active monitors
for mon in "${active_monitors[@]}"; do
  wp="${wallpapers[$mon]:-$all_wallpaper}"
  if [ -n "$wp" ]; then
    swaylock_cmd+=" -i \"$mon:$wp\""
  fi
done

# Run the command
eval "$swaylock_cmd"
