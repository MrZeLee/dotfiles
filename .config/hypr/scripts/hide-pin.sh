#!/usr/bin/env bash

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

# Iterate over each Hyprland client
echo "$windows" | jq -c '.[]' | while read -r window; do
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
          hyprctl dispatch tagwindow +hide address:$address
          hyprctl dispatch movewindowpixel 5000 5000, address:$address
        fi

        # Check if the window's PID matches any audio stream
        object_serial=$(echo "$pipewire_clients" | grep -B4 "pipewire.sec.pid = \"$pid\"" | grep "object.serial = " | awk -F'"' '{print $2}')
        # # Find the object serial for the PID in PipeWire clients
        # object_serial=$(echo "$pipewire_clients" | awk -v pid="$pid" '
        #     /pipewire.sec.pid/ && $0 ~ pid { found=1 }
        #     found && /object.serial/ { gsub(/[^0-9]/, "", $2); print $2; exit }')

        if [ -n "$object_serial" ]; then
          stream=$(echo "$audio_streams" | jq -c --arg object_serial "$object_serial" '.[] | select(.client == $object_serial and .corked == false)')
          
          if [ -n "$stream" ]; then
              # Send a space key to the window
              hyprctl dispatch sendshortcut none, space, address:$address
          fi
        fi
    fi
done
