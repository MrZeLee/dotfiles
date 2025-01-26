#!/usr/bin/env bash

# Validate arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <grid_rows> <grid_cols> <target_row> <target_col>"
    exit 1
fi

# Input arguments
grid_rows=$1
grid_cols=$2
target_row=$3
target_col=$4

# Validate grid dimensions and target position
if [ "$grid_rows" -le 0 ] || [ "$grid_cols" -le 0 ]; then
    echo "Grid dimensions must be greater than zero."
    exit 1
fi

if [ "$target_row" -lt 0 ] || [ "$target_row" -ge "$grid_rows" ] || [ "$target_col" -lt 0 ] || [ "$target_col" -ge "$grid_cols" ]; then
    echo "Target row and column must be within the grid dimensions."
    exit 1
fi

# Get the active window's ID
active_window=$(hyprctl activewindow -j | jq -r '.address')
if [ -z "$active_window" ]; then
    echo "No active window found."
    exit 1
fi

# Get monitor details
monitors=$(hyprctl monitors -j)

# Get the monitor where the active window is
monitor=$(hyprctl clients -j | jq -r --arg active "$active_window" '.[] | select(.address == $active) | .monitor')
if [ -z "$monitor" ]; then
    echo "Could not determine monitor for the active window."
    exit 1
fi

# Get monitor dimensions and position
monitor_info=$(echo $monitors | jq -r --arg monitor "$monitor" ".[] | select(.id == $monitor)")
monitor_x=$(echo "$monitor_info" | jq -r '.x')
monitor_y=$(echo "$monitor_info" | jq -r '.y')

# Check if monitor is transformed
transform=$(echo "$monitor_info" | jq -r '.transform')
monitor_width=$(echo "$monitor_info" | jq -r '.width')
monitor_height=$(echo "$monitor_info" | jq -r '.height')

# Check transform value and swap width and height if necessary
if [ "$transform" -eq 1 ] || [ "$transform" -eq 3 ]; then
    temp_width=$monitor_width
    monitor_width=$monitor_height
    monitor_height=$temp_width
fi

# Get the window dimensions
window_info=$(hyprctl clients -j | jq -r --arg active "$active_window" '.[] | select(.address == $active)')
window_width=$(echo "$window_info" | jq -r '.size[0]')
window_height=$(echo "$window_info" | jq -r '.size[1]')

# Calculate cell size
cell_width=$(echo "($monitor_width - $window_width) / ($grid_cols - 1)" | bc)
cell_height=$(echo "($monitor_height - $window_height) / ($grid_rows - 1)" | bc)

# Calculate top-left corner position for the window
float_x=$(echo "$monitor_x + $target_col * $cell_width" | bc)
float_y=$(echo "$monitor_y + $target_row * $cell_height" | bc)
if [ "$target_row" -eq 0 ]; then
  float_y=$(echo "$float_y + 24" | bc)
fi

# # Adjust for the window's top-left corner
# adjusted_x=$(echo "$float_x - $window_width / 2" | bc)
# adjusted_y=$(echo "$float_y - $window_height / 2" | bc)

# Move the window to the calculated position
hyprctl -r --quiet --batch "dispatch movewindowpixel exact ${float_x} ${float_y}, address:$active_window"

