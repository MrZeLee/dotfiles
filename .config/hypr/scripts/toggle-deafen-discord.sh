#!/usr/bin/env bash

# Check if Discord is already focused
current_window=$(hyprctl activewindow -j | jq -r '.initialTitle')
if [[ "$current_window" != "Discord" ]]; then
  hyprctl dispatch focuswindow initialtitle:^Discord$ -q
  hyprctl dispatch sendshortcut CTRL_SHIFT, D, initialtitle:^Discord$ -q
  hyprctl dispatch focuscurrentorlast -q
else
  hyprctl dispatch sendshortcut CTRL_SHIFT, D, initialtitle:^Discord$ -q
fi
