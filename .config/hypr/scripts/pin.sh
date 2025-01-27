#!/usr/bin/env bash

# Get the active window's ID
active_window=$(hyprctl activewindow -j | jq -r '.address')
echo "active_window=$active_window"
if [ -z "$active_window" ]; then
    echo "No active window found."
    exit 1
fi

# Get monitor details
monitors=$(hyprctl monitors -j)

# Get the monitor where the active window is
monitor=$(hyprctl clients -j | jq -r --arg active "$active_window" '.[] | select(.address == $active) | .monitor')
echo "monitor=$monitor"
if [ -z "$monitor" ]; then
    echo "Could not determine monitor for the active window."
    exit 1
fi

# Get monitor dimensions and position
monitor_info=$(echo $monitors | jq -r --arg monitor "$monitor" ".[] | select(.id == $monitor)")
monitor_x=$(echo "$monitor_info" | jq -r '.x')
monitor_y=$(echo "$monitor_info" | jq -r '.y')

#check if monitor is transformed
transform=$(echo "$monitor_info" | jq -r '.transform')
monitor_width=$(echo "$monitor_info" | jq -r '.width')
monitor_height=$(echo "$monitor_info" | jq -r '.height')

# Check transform value and swap width and height if necessary
if [ "$transform" -eq 1 ] || [ "$transform" -eq 3 ]; then
    temp_width=$monitor_width
    monitor_width=$monitor_height
    monitor_height=$temp_width
fi

# Calculate floating window dimensions (16:9 aspect ratio, 30% of monitor size)
if (( $(echo "$monitor_width / $monitor_height > 16 / 9" | bc -l) )); then
    # If the monitor is wider than 16:9, base calculation on the height
    float_height=$(echo "$monitor_height * 0.3" | bc | awk '{print int($1+0.5)}')
    float_width=$(echo "$float_height * 16 / 9" | bc | awk '{print int($1+0.5)}')
else
    # If the monitor is narrower than 16:9, base calculation on the width
    float_width=$(echo "$monitor_width * 0.3" | bc | awk '{print int($1+0.5)}')
    float_height=$(echo "$float_width * 9 / 16" | bc | awk '{print int($1+0.5)}')
fi

# # Calculate floating window dimensions (16:9 aspect ratio, 30% of monitor width)
# float_width=$(echo "$monitor_width * 0.3" | bc | awk '{print int($1+0.5)}')
# float_height=$(echo "$float_width * 9 / 16" | bc | awk '{print int($1+0.5)}')

# Calculate centered position for the floating window
float_x=$(echo "$monitor_x + ($monitor_width - $float_width) / 2" | bc | awk '{print int($1+0.5)}')
float_y=$(echo "$monitor_y + ($monitor_height - $float_height) / 2" | bc | awk '{print int($1+0.5)}')

# Set the window to floating and resize/move it
hyprctl -r --quiet --batch "dispatch setfloating address:$active_window; dispatch resizewindowpixel exact ${float_width} ${float_height}, address:$active_window; dispatch movewindowpixel exact ${float_x} ${float_y}, address:$active_window; dispatch pin address:$active_window"
