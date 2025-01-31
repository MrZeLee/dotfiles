#!/usr/bin/env bash

waypaper_list=$(waypaper --list)
if [ -z "$waypaper_list" ]; then
  echo "No wallpaper list found."
  exit 1
fi

# Initialize the swaylock command
swaylock_cmd="swaylock -f -e -s stretch -c 000000"

while read -r elem; do
  monitor=$(echo "$elem" | jq -r '.monitor')
  wallpaper=$(echo "$elem" | jq -r '.wallpaper')

  
  # Append the -i argument for swaylock
  swaylock_cmd+=" -i \"$monitor:$wallpaper\""
done < <(echo "$waypaper_list" | jq -c '.[]')

eval "$swaylock_cmd"
