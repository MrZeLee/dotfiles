#!/usr/bin/env bash

# Get the active window's ID
active_window="$(hyprctl activewindow -j)"
active_window_address="$(echo "$active_window" | jq -r '.address')"
active_window_class="$(echo "$active_window" | jq -r '.class')"
active_window_initialtitle="$(echo "$active_window" | jq -r '.initialTitle')"

if [ -z "$active_window_address" ]; then
    echo "No active window found."
    exit 1
fi

if [[ "$active_window_class" = "firefox" && "$active_window_initialtitle" != "Picture-in-Picture" ]]; then
  clients_start_addresses="$(hyprctl clients -j | jq -r '.[] | select(.class == "firefox" and .initialTitle == "Picture-in-Picture") | .address')"
  hyprctl --quiet dispatch sendshortcut CTRL_SHIFT, bracketright, activeWindow
fi

# Get monitor details
monitors=$(hyprctl monitors -j)

# Get the monitor where the active window is
monitor=$(hyprctl clients -j | jq -r --arg active "$active_window_address" '.[] | select(.address == $active) | .monitor')
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

if [[ "$active_window_class" = "firefox" && "$active_window_initialtitle" != "Picture-in-Picture" ]]; then
  clients_end="$(hyprctl clients -j)"
  clients_end_addresses="$(echo "$clients_end" | jq -r '.[] | select(.class == "firefox" and .initialTitle == "Picture-in-Picture") | .address')"
  
  # Find new PiP windows by comparing start and end lists
  new_window=""
  if [ -n "$clients_end_addresses" ]; then
      if [ -z "$clients_start_addresses" ]; then
          # If there was no PiP window before, the end result is the new window
          new_window="$clients_end_addresses"
      else
          # Compare start and end lists to find new addresses
          while IFS= read -r end_address; do
              if [[ ! "$clients_start_addresses" =~ "$end_address" ]]; then
                check="$(echo "$clients_end" | jq -r --arg add "$clients_end" '.[] | select(.address == $end_address and .class == "firefox" and .initialTitle == "Picture-in-Picture")')"
                if [ -z "$check" ]; then
                  new_window="$end_address"
                  break
                fi
              fi
          done <<< "$clients_end_addresses"
      fi
  fi
  
  # If we found a new PiP window, use its address instead of the active window
  if [ -n "$new_window" ]; then
      active_window_address="$new_window"
  fi
fi

# Set the window to floating and resize/move it
hyprctl -r --quiet --batch "dispatch setfloating address:$active_window_address; dispatch tagwindow +float address:$active_window_address; dispatch resizewindowpixel exact ${float_width} ${float_height}, address:$active_window_address; dispatch movewindowpixel exact ${float_x} ${float_y}, address:$active_window_address; dispatch pin address:$active_window_address"
