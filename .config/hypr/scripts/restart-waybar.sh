#!/usr/bin/env bash

WAYBAR_CMD="waybar -c $HOME/.config/waybar/${HYPRLAND_HOST}_config.jsonc"

while [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; do
  sleep 1
done


if pgrep -fx "$WAYBAR_CMD" >/dev/null; then
    # Waybar is running, so kill it
    if [[ $# -gt 0 && "$1" == "set" ]]; then
      :
    else
      pkill -fx "$WAYBAR_CMD"
    fi
else
    # Waybar is not running, so launch it
    $WAYBAR_CMD | tee -a /tmp/waybar.log &
fi
