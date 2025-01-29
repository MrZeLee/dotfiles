#!/usr/bin/env bash

on=$(hyprctl -j getoption animations:enabled | jq --raw-output '.int')
hyprctl -q keyword animations:enabled 0

# Get Hyprland clients
windows=$(hyprctl clients -j)
if [ -z "$windows" ]; then
  echo "No windows found."
  exit 1
fi

# Get sink inputs from pactl
audio_streams=$(pactl --format json list sink-inputs)
if [ -z "$audio_streams" ]; then
  echo "No audio streams found."
  exit 1
fi

# Get the PipeWire clients from pw-cli
pipewire_clients=$(pw-cli list-objects)
if [ -z "$pipewire_clients" ]; then
  echo "No PipeWire clients found."
  exit 1
fi

count=0

# Iterate over each Hyprland client
while read -r window; do
  # Extract window details
  pid=$(echo "$window" | jq -r '.pid')
  floating=$(echo "$window" | jq -r '.floating')
  pinned=$(echo "$window" | jq -r '.pinned')
  address=$(echo "$window" | jq -r '.address')
  tags=$(echo "$window" | jq -r '.tags')

  # Check if the window is floating or pinned
  if [ "$floating" == "true" ] && [[ "$pinned" == "true" ]]; then
    if [[ ! "$tags" == *"\"hide\""* ]]; then
      # Hide the window
      hyprctl -q dispatch tagwindow +hide address:$address
      hyprctl -q dispatch movewindowpixel 5000 5000, address:$address
      ((count++))

      # Check if the window's PID matches any audio stream
      object_serial=$(echo "$pipewire_clients" | grep -B4 "pipewire.sec.pid = \"$pid\"" | grep "object.serial = " | awk -F'"' '{print $2}')

      stream=$(echo "$audio_streams" | jq -c --arg window_pid "$pid" '.[] | select(.properties."application.process.id" == $window_pid and .corked == false)')

      if [ -n "$object_serial" ] || [ -n "$stream" ]; then
        if [ -z "$stream" ]; then
          stream=$(echo "$audio_streams" | jq -c --arg object_serial "$object_serial" '.[] | select(.client == $object_serial and .corked == false)')
        fi

        if [ -n "$stream" ]; then
          # Send a space key to the window
          hyprctl -q dispatch tagwindow +paused address:$address
          # hyprctl -q dispatch focuswindow address:$address
          hyprctl -q dispatch sendshortcut none, space, address:$address
          # hyprctl -q dispatch focuscurrentorlast
        fi
      fi
    fi
  fi
done < <(echo "$windows" | jq -c '.[]') 

# If no windows were hidden, restore windows with the "hide" tag
if [ "$count" -eq 0 ]; then
  echo "$windows" | jq -c '.[]' | while read -r window; do
    address=$(echo "$window" | jq -r '.address')
    tags=$(echo "$window" | jq -r '.tags')

      # Check if the window has the "hide" tag
      if [[ "$tags" == *"\"hide\""* ]]; then
        # Remove the "hide" tag and move the window back
        hyprctl -q dispatch movewindowpixel -5000 0, address:$address
        hyprctl -q dispatch movewindowpixel "0 -5000", address:$address
        hyprctl -q dispatch tagwindow -- -hide address:$address
      fi
      if [[ "$tags" == *"\"paused\""* ]]; then
        # hyprctl -q dispatch focuswindow address:$address
        hyprctl -q dispatch sendshortcut none, space, address:$address
        # hyprctl -q dispatch focuscurrentorlast
        hyprctl -q dispatch tagwindow -- -paused address:$address
      fi
  done
fi

hyprctl -q keyword animations:enabled "$on"
