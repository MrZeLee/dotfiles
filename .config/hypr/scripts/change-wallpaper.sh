#!/usr/bin/env bash

activemonitor=$(hyprctl activeworkspace -j | jq --raw-output '.monitor')
if [ -z "$activemonitor" ]; then
  echo "No active Monitor found."
  exit 1
fi

# Query the monitor details using swww
monitor_info=$(swww query | grep "$activemonitor")

# Extract resolution (x and y) from the monitor info
resolution=$(echo "$monitor_info" | grep -oP '\d+x\d+' | head -n 1)
x=$(echo "$resolution" | cut -d'x' -f1)
y=$(echo "$resolution" | cut -d'x' -f2)

# Calculate the aspect ratio and format it to 2 decimal places
aspect_ratio=$(echo "scale=2; $x/$y" | bc | awk '{printf "%.2f", $0}')

# Treat 16:10 (1.60) as 16:9 (1.77) for wallpaper selection
if [ "$aspect_ratio" = "1.60" ]; then
  aspect_ratio="1.77"
fi

waypaper --random --fill stretch --folder "$HOME/.config/waypaper/wallpapers/$aspect_ratio" --backend swww --monitor "$activemonitor" &> /dev/null

# If there's only one monitor connected, also apply the wallpaper to all monitors
monitor_count=$(hyprctl monitors -j | jq 'length')
if [ "$monitor_count" -eq 1 ]; then
  waypaper --random --fill stretch \
    --folder "$HOME/.config/waypaper/wallpapers/$aspect_ratio" \
    --backend swww &> /dev/null
fi
