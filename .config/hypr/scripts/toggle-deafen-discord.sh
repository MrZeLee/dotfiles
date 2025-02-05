#!/usr/bin/env bash

# Check if Discord is already focused
current_window_address=$(hyprctl activewindow -j | jq -r '.address')

discord_address=$(hyprctl clients -j | jq -r '[.[] | select(.initialClass == "vesktop" and .initialTitle != "Discord Popout")][0] | .address')

if [[ "$current_window_address" != "$discord_address" ]]; then
  hyprctl dispatch focuswindow address:$discord_address -q
  hyprctl dispatch sendshortcut CTRL_SHIFT, D, address:$discord_address -q
  hyprctl dispatch focuscurrentorlast -q
else
  hyprctl dispatch sendshortcut CTRL_SHIFT, D, address:$discord_address -q
fi
